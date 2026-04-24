package com.techhub.schoolScout

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.*
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class SchoolNativeAdFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {

        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_school_ad, null) as NativeAdView

        adView.findViewById<TextView>(R.id.ad_headline).text = nativeAd.headline
        adView.findViewById<TextView>(R.id.ad_body).text = nativeAd.body
        adView.findViewById<Button>(R.id.ad_call_to_action).text = nativeAd.callToAction

        val iconView = adView.findViewById<ImageView>(R.id.ad_app_icon)
        if (nativeAd.icon != null) {
            iconView.setImageDrawable(nativeAd.icon!!.drawable)
        }

        adView.headlineView = adView.findViewById(R.id.ad_headline)
        adView.bodyView = adView.findViewById(R.id.ad_body)
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        adView.iconView = iconView

        adView.setNativeAd(nativeAd)

        return adView
    }
}
