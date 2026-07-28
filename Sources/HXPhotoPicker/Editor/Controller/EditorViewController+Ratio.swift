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
                buttonType = referenceRatio.width < referenceRatio.height ? 0 : 1
                scaleSwitchSelectType = buttonType
                editorView.setAspectRatio(referenceRatio, animated: true)
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
