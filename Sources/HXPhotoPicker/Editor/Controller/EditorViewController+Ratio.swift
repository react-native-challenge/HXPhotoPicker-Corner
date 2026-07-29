//
//  EditorViewController+Ratio.swift
//  HXPhotoPicker
//
//  Created by Silence on 2023/5/17.
//

import UIKit

extension EditorViewController {
    /// 是否支持调转比例方向（原始比例及所有非 1:1 的固定比例）
    func isAspectRatioScaleSwitchable(_ ratio: CGSize) -> Bool {
        if ratio.equalTo(.zero) {
            return false
        }
        if ratio.width < 0 || ratio.height < 0 {
            return true
        }
        if ratio.width == ratio.height {
            return false
        }
        return ratio.width > 0 && ratio.height > 0
    }
    
    /// 调转比例方向时的参考比例
    func scaleSwitchReferenceRatio(for ratio: CGSize) -> CGSize {
        if ratio.width < 0 || ratio.height < 0 {
            return editorView.originalAspectRatio
        }
        return ratio
    }
    
    /// 默认选中的横竖屏方向（0: 竖屏, 1: 横屏）
    func defaultScaleSwitchSelectType(for referenceRatio: CGSize) -> Int {
        if config.cropSize.isPreferPortraitAspectRatio,
           referenceRatio.width > 0,
           referenceRatio.height > 0,
           referenceRatio.width != referenceRatio.height {
            return 0
        }
        return referenceRatio.width < referenceRatio.height ? 0 : 1
    }
    
    /// 开启竖屏优先后，将横屏比例配置转换为实际应用的竖屏比例
    func resolvedPortraitPreferringAspectRatio(_ ratio: CGSize) -> CGSize {
        guard config.cropSize.isPreferPortraitAspectRatio,
              isAspectRatioScaleSwitchable(ratio),
              ratio.width > ratio.height else {
            return ratio
        }
        return .init(width: ratio.height, height: ratio.width)
    }
    
    /// 根据选中的方向应用比例
    func applyScaleSwitchAspectRatio(referenceRatio: CGSize, selectType: Int) {
        if selectType == 0 {
            if referenceRatio.width < referenceRatio.height {
                editorView.setAspectRatio(referenceRatio, animated: true)
            } else {
                editorView.setAspectRatio(.init(width: referenceRatio.height, height: referenceRatio.width), animated: true)
            }
        } else {
            if referenceRatio.width < referenceRatio.height {
                editorView.setAspectRatio(.init(width: referenceRatio.height, height: referenceRatio.width), animated: true)
            } else {
                editorView.setAspectRatio(referenceRatio, animated: true)
            }
        }
    }
}

extension EditorViewController: EditorRatioToolViewDelegate {
    func ratioToolView(_ ratioToolView: EditorRatioToolView, didSelectedRatioAt ratio: CGSize) {
        if isAspectRatioScaleSwitchable(ratio) {
            editorView.isFixedRatio = true
            let referenceRatio = scaleSwitchReferenceRatio(for: ratio)
            let buttonType: Int
            if let selectType = scaleSwitchSelectType {
                buttonType = selectType
                applyScaleSwitchAspectRatio(referenceRatio: referenceRatio, selectType: selectType)
            } else {
                buttonType = defaultScaleSwitchSelectType(for: referenceRatio)
                scaleSwitchSelectType = buttonType
                applyScaleSwitchAspectRatio(referenceRatio: referenceRatio, selectType: buttonType)
            }
            scaleSwitchLeftBtn.isSelected = buttonType == 0
            scaleSwitchRightBtn.isSelected = buttonType == 1
            showScaleSwitchView(UIDevice.isPortrait)
            hideMasks()
        } else {
            hideScaleSwitchView(UIDevice.isPortrait)
            editorView.isFixedRatio = ratio != .zero
            if editorView.isFixedRatio {
                editorView.setAspectRatio(ratio, animated: true)
            }
        }
        resetButton.isEnabled = isReset
    }
}
