package com.example.internet_connection_status

import com.example.internet_connection_status.InternetConnectionApi

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities

class InternetConnectionApiImpl(private val context: Context) : InternetConnectionApi {
  override fun hasInternetConnection(): Boolean {
    val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    val network = connectivityManager.activeNetwork ?: return false
    val networkCapabilities = connectivityManager.getNetworkCapabilities(network) ?: return false
    return networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
           networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
  }
}