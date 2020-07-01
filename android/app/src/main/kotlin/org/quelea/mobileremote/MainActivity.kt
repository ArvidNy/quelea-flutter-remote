package org.quelea.mobileremote

import android.content.SharedPreferences
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        val sharedPreference: SharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", 0)
        if (sharedPreference.getBoolean("flutter.pref_use_volume_navigation", false) && (keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN)) {
            return true
        }
        return super.onKeyDown(keyCode, event)
    }
}
