package com.zeropuff.app

import android.annotation.SuppressLint
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

/** A quick-settings tile that opens the craving rescue from anywhere. */
class CravingTileService : TileService() {
    override fun onStartListening() {
        super.onStartListening()
        qsTile?.apply {
            state = Tile.STATE_INACTIVE
            updateTile()
        }
    }

    @SuppressLint("StartActivityAndCollapseDeprecated")
    override fun onClick() {
        super.onClick()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivityAndCollapse(LaunchRoute.pendingIntent(this, LaunchRoute.RESCUE, 3))
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(LaunchRoute.intent(this, LaunchRoute.RESCUE))
        }
    }
}
