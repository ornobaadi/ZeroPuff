package com.zeropuff.app

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Shaped vibration patterns for the rescue flow and small moments of feedback.
 *
 * Long breaths are amplitude ramps; short moments use composition primitives
 * where the device supports them and plain one-shots otherwise.
 */
class HapticsChannel(context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        const val NAME = "zeropuff/haptics"
        private const val STEP_MS = 40L
    }

    private val vibrator: Vibrator? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager)
                ?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val device = vibrator
        if (device == null || !device.hasVibrator() || Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            // The Dart side falls back to the system's basic feedback.
            result.error("unsupported", "No shaped vibration on this device", null)
            return
        }

        when (call.method) {
            "cancel" -> {
                device.cancel()
                result.success(null)
            }
            "play" -> {
                val pattern = call.argument<String>("pattern")
                val durationMs = (call.argument<Number>("durationMs") ?: 4000).toLong()
                val scale = (call.argument<Number>("scale") ?: 1.0).toFloat().coerceIn(0.1f, 1f)
                val effect = effectFor(device, pattern, durationMs, scale)
                if (effect == null) {
                    result.notImplemented()
                    return
                }
                device.cancel()
                device.vibrate(effect)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun effectFor(
        device: Vibrator,
        pattern: String?,
        durationMs: Long,
        scale: Float,
    ): VibrationEffect? = when (pattern) {
        "inhale" -> ramp(device, durationMs, from = 12, to = (170 * scale).toInt())
        "exhale" -> ramp(device, durationMs, from = (150 * scale).toInt(), to = 0)
        "tick" -> primitive(device, VibrationEffect.Composition.PRIMITIVE_TICK, scale)
            ?: VibrationEffect.createOneShot(12, amplitude(device, 70 * scale))
        "coin" -> composed(device) {
            addPrimitive(VibrationEffect.Composition.PRIMITIVE_QUICK_FALL, scale)
            addPrimitive(VibrationEffect.Composition.PRIMITIVE_CLICK, scale, 60)
            addPrimitive(VibrationEffect.Composition.PRIMITIVE_TICK, scale * 0.6f, 90)
        } ?: waveform(device, longArrayOf(0, 30, 70, 18, 80, 12), intArrayOf(0, 200, 0, 150, 0, 90), scale)
        "heartbeat" -> waveform(
            device,
            longArrayOf(0, 55, 110, 80),
            intArrayOf(0, 150, 0, 230),
            scale,
        )
        "milestone_small" -> waveform(
            device,
            longArrayOf(0, 40, 90, 60),
            intArrayOf(0, 140, 0, 220),
            scale,
        )
        "milestone_medium" -> waveform(
            device,
            longArrayOf(0, 40, 80, 40, 80, 120),
            intArrayOf(0, 120, 0, 170, 0, 240),
            scale,
        )
        "milestone_large" -> waveform(
            device,
            longArrayOf(0, 40, 70, 40, 70, 40, 70, 60, 120, 260),
            intArrayOf(0, 100, 0, 140, 0, 180, 0, 220, 0, 255),
            scale,
        )
        else -> null
    }

    /** A smooth rise or fall, or quickening/slowing pulses without amplitude control. */
    private fun ramp(device: Vibrator, durationMs: Long, from: Int, to: Int): VibrationEffect {
        val total = durationMs.coerceIn(400, 12000)
        if (device.hasAmplitudeControl()) {
            val steps = (total / STEP_MS).toInt().coerceAtLeast(2)
            val timings = LongArray(steps) { STEP_MS }
            val amplitudes = IntArray(steps) { index ->
                val t = index.toFloat() / (steps - 1)
                (from + (to - from) * t).toInt().coerceIn(0, 255)
            }
            return VibrationEffect.createWaveform(timings, amplitudes, -1)
        }

        val rising = to > from
        val timings = ArrayList<Long>()
        var elapsed = 0L
        while (elapsed < total) {
            val t = elapsed.toFloat() / total
            val gap = if (rising) 260 - (190 * t) else 70 + (190 * t)
            timings.add(gap.toLong())
            timings.add(22)
            elapsed += gap.toLong() + 22
        }
        return VibrationEffect.createWaveform(timings.toLongArray(), -1)
    }

    private fun waveform(
        device: Vibrator,
        timings: LongArray,
        amplitudes: IntArray,
        scale: Float,
    ): VibrationEffect {
        if (!device.hasAmplitudeControl()) {
            return VibrationEffect.createWaveform(timings, -1)
        }
        val scaled = IntArray(amplitudes.size) { (amplitudes[it] * scale).toInt().coerceIn(0, 255) }
        return VibrationEffect.createWaveform(timings, scaled, -1)
    }

    private fun amplitude(device: Vibrator, value: Float): Int =
        if (device.hasAmplitudeControl()) value.toInt().coerceIn(1, 255)
        else VibrationEffect.DEFAULT_AMPLITUDE

    private fun primitive(device: Vibrator, id: Int, scale: Float): VibrationEffect? =
        composed(device, id) { addPrimitive(id, scale) }

    private fun composed(
        device: Vibrator,
        vararg required: Int = intArrayOf(
            VibrationEffect.Composition.PRIMITIVE_QUICK_FALL,
            VibrationEffect.Composition.PRIMITIVE_CLICK,
            VibrationEffect.Composition.PRIMITIVE_TICK,
        ),
        build: VibrationEffect.Composition.() -> Unit,
    ): VibrationEffect? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            return null
        }
        if (!device.areAllPrimitivesSupported(*required)) {
            return null
        }
        return VibrationEffect.startComposition().apply(build).compose()
    }
}
