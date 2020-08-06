package com.prolifel.sekretin2

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import java.util.concurrent.Executor

class LoginActivity : AppCompatActivity() {
    private lateinit var executor: Executor
    private lateinit var biometricPrompt: BiometricPrompt
    private lateinit var promptInfo: BiometricPrompt.PromptInfo

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Hide Action Bar
        supportActionBar?.hide()

        setContentView(R.layout.activity_login)

        val buttonLogin = findViewById<Button>(R.id.button_login)
        val email = findViewById<EditText>(R.id.login_email)
        val password = findViewById<EditText>(R.id.login_password)
        val intent = Intent(this@LoginActivity, HomeScreen::class.java)

        // Logic buat Log In
        buttonLogin.setOnClickListener(View.OnClickListener {
            if (email.text.toString() == "admin" && password.text.toString() == "1234"){
                Toast.makeText(this, "Log In Berhasil", Toast.LENGTH_SHORT).show()
                startActivity(intent)
                finish()
            }else
                Toast.makeText(this, "Email dan Password salah!", Toast.LENGTH_SHORT).show()
        })

        // Validation for biometric hardware
        val biometricManager = BiometricManager.from(this)
        when (biometricManager.canAuthenticate()) {
            BiometricManager.BIOMETRIC_SUCCESS ->
                Log.d("MY_APP_TAG", "App can authenticate using biometrics.")
            BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE ->
                Log.e("MY_APP_TAG", "No biometric features available on this device.")
            BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE ->
                Log.e("MY_APP_TAG", "Biometric features are currently unavailable.")
            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED ->
                Log.e("MY_APP_TAG", "The user hasn't associated " +
                        "any biometric credentials with their account.")
        }

        // Template biometric login
        executor = ContextCompat.getMainExecutor(this)
        biometricPrompt = BiometricPrompt(this, executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(errorCode: Int,
                                                   errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    Toast.makeText(applicationContext,
                        "Autentikasi gagal: $errString", Toast.LENGTH_SHORT)
                        .show()
                }

                override fun onAuthenticationSucceeded(
                    result: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(result)
                    Toast.makeText(applicationContext,
                        "Log In Berhasil", Toast.LENGTH_SHORT)
                        .show()
                    startActivity(intent)
                    finish()
                }

                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    Toast.makeText(applicationContext, "Autentikasi gagal",
                        Toast.LENGTH_SHORT)
                        .show()
                }
            })

        promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Biometric Login")
            .setSubtitle("Silakan login dengan biometrik anda")
            .setDeviceCredentialAllowed(true)
            .build()
        biometricPrompt.authenticate(promptInfo)
    }
}