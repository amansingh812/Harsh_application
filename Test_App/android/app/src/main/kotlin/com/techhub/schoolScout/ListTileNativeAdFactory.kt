package com.techhub.schoolScout

import android.content.Context
import android.view.LayoutInflater
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class ListTileNativeAdFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {

        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_list_tile, null) as NativeAdView

        adView.headlineView = adView.findViewById(R.id.ad_headline)

        (adView.headlineView as android.widget.TextView).text =
            nativeAd.headline

        adView.setNativeAd(nativeAd)

        return adView
    }
}
