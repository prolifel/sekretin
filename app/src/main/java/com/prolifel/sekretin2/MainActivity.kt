package com.prolifel.sekretin2

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.WindowManager
import android.view.animation.AnimationUtils
import android.widget.ImageView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import java.util.concurrent.Executor

class MainActivity : AppCompatActivity() {
    private lateinit var executor: Executor
    private lateinit var biometricPrompt: BiometricPrompt
    private lateinit var promptInfo: BiometricPrompt.PromptInfo

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Setting Fullscreen
        this.window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
        setContentView(R.layout.activity_main)

        // Hide Action Bar
        supportActionBar?.hide()

        val logoSplash = findViewById<ImageView>(R.id.logoSplash)

        Handler().postDelayed({
            val intent = Intent(this@MainActivity, LoginActivity::class.java)
            startActivity(intent)
            finish()
        }, 2500)

        val animationLogo =
            AnimationUtils.loadAnimation(applicationContext, R.anim.zoom_fade)
        logoSplash.startAnimation(animationLogo)
    }
}