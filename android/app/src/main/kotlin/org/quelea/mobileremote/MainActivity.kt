package org.quelea.mobileremote

import android.content.SharedPreferences
import android.os.Handler
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import java.net.URL
import kotlin.concurrent.thread


class MainActivity : FlutterActivity() {

    private var longPress = false
    private var returnState = false
    private var doubleClicked = false
    private var clickCount = 0
    private var singleClick: Long = 0
    private var doubleClick: Long = 0

    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        if (isUseVolume()) {
            return when (keyCode) {
                KeyEvent.KEYCODE_VOLUME_UP -> {
                    event.startTracking()
                    true
                }
                KeyEvent.KEYCODE_VOLUME_DOWN -> {
                    event.startTracking()
                    true
                }
                else -> false
            }
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun onKeyLongPress(keyCode: Int, event: KeyEvent?): Boolean {
        if (!longPress) {
            if (!doubleClicked) {
                if (isUseVolume()) {
                    longPress = true
                    when (getLongPressAction()) {
                        "slide" -> sendSlideAction(keyCode)
                        "item" -> sendItemAction(keyCode)
                        "clear" -> sendAction("clear")
                        "black" -> sendAction("black")
                        "logo" -> sendAction("tlogo")
                        "nothing" -> return false
                    }
                    return true
                }
            } else doubleClicked = false
            return false
        }
        return super.onKeyLongPress(keyCode, event)
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        if (isUseVolume()) {
            if (!longPress && keyCode != 26) clickCount++
            returnState = false
            val handler = Handler()
            val r = Runnable {
                if (clickCount == 1) {
                    singleClick = System.currentTimeMillis()
                    val diff: Long = singleClick - doubleClick
                    if (diff > 300) {
                        returnState = true
                        sendSlideAction(keyCode)
                    }
                }
                clickCount = 0
            }
            if (clickCount == 1) {
                // Single click
                if (doubleClicked) doubleClicked = false
                handler.postDelayed(r, 150)
            } else if (clickCount == 2) {
                // Double click
                doubleClick = System.currentTimeMillis()
                doubleClicked = true
                if (isUseVolume()
                        && (keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN)) {
                    when (getDoublePressAction()) {
                        "slide" -> sendAction("next")
                        "item" -> sendAction("nextitem")
                        "clear" -> sendAction("clear")
                        "black" -> sendAction("black")
                        "logo" -> sendAction("tlogo")
                        "nothing" -> return false
                    }
                } else return false
                clickCount = 0
                returnState = true
            }
            if (longPress) {
                longPress = false
            }
            return returnState
        }
        return super.onKeyUp(keyCode, event)
    }

    private fun isUseVolume(): Boolean {
        val sharedPreference: SharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", 0)
        return sharedPreference.getBoolean("flutter.pref_use_volume_navigation", false)
    }

    private fun getLongPressAction(): String? {
        val sharedPreference: SharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", 0)
        return sharedPreference.getString("flutter.pref_long_volume_action", "nothing")
    }

    private fun getDoublePressAction(): String? {
        val sharedPreference: SharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", 0)
        return sharedPreference.getString("flutter.pref_double_volume_action", "nothing")
    }

    private fun sendItemAction(keyCode: Int) {
        if(keyCode == KeyEvent.KEYCODE_VOLUME_UP){
            sendAction("previtem")
        } else if(keyCode == KeyEvent.KEYCODE_VOLUME_DOWN){
            sendAction("nextitem")
        }
    }

    private fun sendSlideAction(keyCode: Int) {
        if(keyCode == KeyEvent.KEYCODE_VOLUME_UP){
            sendAction("prev")
        } else if(keyCode == KeyEvent.KEYCODE_VOLUME_DOWN){
            sendAction("next")
        }
    }

    private fun sendAction(action: String): Boolean {
        val sharedPreference: SharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", 0)
        thread(start = true) {
            URL("${sharedPreference.getString("flutter.pref_server_url", "http://192.168.0.1:1112")}/$action").readText()
        }
        return true
    }

}
