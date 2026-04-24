import UIKit
import Flutter
import google_mobile_ads

class ListTileNativeAdFactory: NSObject, FLTNativeAdFactory {

    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [AnyHashable : Any]?
    ) -> GADNativeAdView {

        let adView = GADNativeAdView()
        adView.backgroundColor = .white
        adView.layer.cornerRadius = 14
        adView.clipsToBounds = true

        // Icon
        let iconView = UIImageView()
        iconView.layer.cornerRadius = 6
        iconView.clipsToBounds = true
        iconView.translatesAutoresizingMaskIntoConstraints = false
        adView.iconView = iconView
        iconView.image = nativeAd.icon?.image

        // Headline
        let headlineLabel = UILabel()
        headlineLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        headlineLabel.numberOfLines = 2
        headlineLabel.text = nativeAd.headline
        adView.headlineView = headlineLabel

        // CTA
        let ctaButton = UIButton(type: .system)
        ctaButton.setTitle(nativeAd.callToAction, for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        ctaButton.backgroundColor = .systemBlue
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.layer.cornerRadius = 6
        adView.callToActionView = ctaButton

        // Text stack
        let textStack = UIStackView(arrangedSubviews: [headlineLabel, ctaButton])
        textStack.axis = .vertical
        textStack.spacing = 6

        // Main row
        let row = UIStackView(arrangedSubviews: [iconView, textStack])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        adView.addSubview(row)

        NSLayoutConstraint.activate([
                                        row.topAnchor.constraint(equalTo: adView.topAnchor, constant: 10),
                                        row.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -10),
                                        row.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 10),
                                        row.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -10),

                                        iconView.widthAnchor.constraint(equalToConstant: 50),
                                        iconView.heightAnchor.constraint(equalToConstant: 50),

                                        ctaButton.heightAnchor.constraint(equalToConstant: 28),
                                        ctaButton.widthAnchor.constraint(equalToConstant: 90)
                                    ])

        adView.nativeAd = nativeAd
        return adView
    }
}
