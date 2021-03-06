//--------------------------------------------------------------------------//
// NovelStudioLint - NovelStudioLint.swift
//
// Copyright 2022 shirajira <contact@novel-stud.io>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//--------------------------------------------------------------------------//

import Foundation

public class NovelStudioLint {

    // MARK: - Properties

    private static let fullWidthWhiteSpace: String = "　"  // Full-width white-space
    private static let lineFeed: String = "\n"  // Line-feed

    // MARK: - Main APIs

    /**
     Delete spaces located at the end of the sentence.
     - parameter sentence: Sentence
     - returns: Formatted sentence
     */
    public static func deleteEndSpaces(sentence: String) -> String {
        let preprocessed = _preprocess(sentence: sentence)
        let paragraphs = _separate(sentence: preprocessed)
        var ret: [String] = []
        for paragraph in paragraphs {
            var formatted: String = ""

            var sourceBuffer = paragraph
            while true {
                formatted = _deleteEndSpace(paragraph: sourceBuffer)
                if formatted == sourceBuffer {
                    break
                }
                sourceBuffer = formatted
            }
            ret.append(formatted)
        }
        return _combine(paragraphs: ret)
    }

    /**
     Insert an indent into each paragraph in the sentence, but dialogs will be ignored.
     - parameter sentence: Sentence
     - parameter considerDashes: Each dashed paragraph is considered as a dialog
     - returns: Indented sentence
     */
    public static func insertIndent(sentence: String, considerDashes: Bool) -> String {
        let preprocessed = _preprocess(sentence: sentence)
        let paragraphs = _separate(sentence: preprocessed)
        var ret: [String] = []
        for paragraph in paragraphs {
            var formatted: String = ""

            if _checkIndented(paragraph: paragraph) {
                formatted = paragraph
            } else if _checkDialogParagraph(paragraph: paragraph, considerDashes: considerDashes) {
                formatted = paragraph
            } else {
                formatted = _indent(paragraph: paragraph)
            }
            ret.append(formatted)
        }
        return _combine(paragraphs: ret)
    }

    /**
     Insert a space after some reserved marks.
     - parameter sentence: Sentence
     - returns: Formatted sentence
     */
    public static func insertSpaceAfterReservedMarks(sentence: String) -> String {
        let preprocessed = _preprocess(sentence: sentence)
        let paragraphs = _separate(sentence: preprocessed)
        var ret: [String] = []
        for paragraph in paragraphs {
            var formatted: String = ""

            // 1) Insert a space anyway.
            formatted = _insertSpace(paragraph: paragraph)

            // 2) Delete unnecessary spaces around some reserved marks.
            var sourceBuffer = formatted
            while true {
                formatted = _deleteUnnecessarySpace(paragraph: sourceBuffer)
                if formatted == sourceBuffer {
                    break
                }
                sourceBuffer = formatted
            }

            // 3) Delete unnecessary spaces located at the end of the paragraph.
            sourceBuffer = formatted
            while true {
                formatted = _deleteEndSpace(paragraph: sourceBuffer)
                if formatted == sourceBuffer {
                    break
                }
                sourceBuffer = formatted
            }
            ret.append(formatted)

        }
        return _combine(paragraphs: ret)
    }

    /**
     Delete spaces before a opening bracket.
     - parameter sentence: Sentence
     - parameter considerDashes: Each dashed paragraph is considered as a dialog
     - returns: Formatted sentence
     */
    public static func deleteSpacesBeforeOpeningBracket(sentence: String, considerDashes: Bool) -> String {
        let preprocessed = _preprocess(sentence: sentence)
        let paragraphs = _separate(sentence: preprocessed)
        var ret: [String] = []
        for paragraph in paragraphs {
            var formatted: String = ""

            var sourceBuffer = paragraph
            while true {
                formatted = _deleteSpaceBeforeOpeningBracket(paragraph: sourceBuffer, considerDashes: considerDashes)
                if formatted == sourceBuffer {
                    break
                }
                sourceBuffer = formatted
            }
            ret.append(formatted)
        }
        return _combine(paragraphs: ret)
    }

    /**
     Delete punctuations before a closing bracket.
     - parameter sentence: Sentence
     - returns: Formatted sentence
     */
    public static func deletePunctuationsBeforeClosingBracket(sentence: String) -> String {
        let preprocessed = _preprocess(sentence: sentence)
        let paragraphs = _separate(sentence: preprocessed)
        var ret: [String] = []
        for paragraph in paragraphs {
            var formatted: String = ""

            var sourceBuffer = paragraph
            while true {
                formatted = _deletePunctuationBeforeClosingBracket(paragraph: sourceBuffer)
                if formatted == sourceBuffer {
                    break
                }
                sourceBuffer = formatted
            }
            ret.append(formatted)
        }
        return _combine(paragraphs: ret)
    }

    /**
     Transform all half-width characters to full-width.
     - parameter sentence: Sentence
     - returns: Transformed sentence
     */
    public static func transformHalfWidthToFull(sentence: String) -> String {
        guard let transformed = sentence.applyingTransform(.fullwidthToHalfwidth, reverse: true) else {
            return sentence
        }
        return transformed
    }

    // MARK: - Utilities

    /**
     Preprocess: Replace half-width marks to full-width.
     - parameter sentence: Sentence may contain half-width marks (white-spaces, brackets and parentheses)
     - returns: Sentence may not contains half-width marks
     */
    internal static func _preprocess(sentence: String) -> String {
        let replacementRule = [
            " ": "　",  // White-space
            "｢": "「",  // Opening bracket
            "｣": "」",  // Closing bracket
            "(": "（",  // Opening parenthesis
            ")": "）"   // Closing parenthesis
        ]
        let ret = replacementRule.reduce(sentence) {
            $0.replacingOccurrences(of: $1.key, with: $1.value)
        }
        return ret
    }

    /**
     Separate a sentence into paragraphs.
     - parameter sentence: Sentence
     - returns: Array of paragraphs
     */
    internal static func _separate(sentence: String) -> [String] {
        let paragraphs = sentence.components(separatedBy: lineFeed)
        return paragraphs
    }

    /**
     Combine paragraphs into a sentence.
     - parameter paragraphs: Array of paragraphs
     - returns: Sentence
     */
    internal static func _combine(paragraphs: [String]) -> String {
        var sentence: String = ""
        for (index, paragraph) in paragraphs.enumerated() {
            sentence += paragraph
            if index != paragraphs.endIndex - 1 {
                sentence += lineFeed
            }
        }
        return sentence
    }

    /**
     Delete a space located at the end of the paragraph.
     - parameter paragraph: Paragraph
     - returns: Modified paragraph
     */
    internal static func _deleteEndSpace(paragraph: String) -> String {
        if paragraph.isEmpty {
            return paragraph
        }
        var ret: String = ""
        let lastCharacter = paragraph.suffix(1)
        if lastCharacter == fullWidthWhiteSpace {
            ret = String(paragraph.prefix(paragraph.count - 1))
        } else {
            ret = paragraph
        }
        return ret
    }

    /**
     Check whether the paragraph is dialog or not.
     - parameter paragraph: Paragraph
     - parameter considerDashes: Each dashed paragraph is considered as a dialog
     - returns: true: Dialog / false: Not dialog
     */
    internal static func _checkDialogParagraph(paragraph: String, considerDashes: Bool) -> Bool {
        if paragraph.isEmpty {
            return false
        }
        var ret: Bool = false
        let firstCharacter = paragraph.prefix(1)
        if firstCharacter == "「" || firstCharacter == "『" || firstCharacter == "（" {
            ret = true
        } else if considerDashes, firstCharacter == "―" {
            ret = true
        }
        return ret
    }

    /**
     Check whether the paragraph is indented or not.
     - parameter paragraph: Paragraph
     - returns: true: Indented / false: Not indented
     */
    internal static func _checkIndented(paragraph: String) -> Bool {
        if paragraph.isEmpty {
            return false
        }
        var ret: Bool = false
        let firstCharacter = paragraph.prefix(1)
        if firstCharacter == fullWidthWhiteSpace {
            ret = true
        }
        return ret
    }

    /**
     Indent the paragraph.
     - parameter paragraph: Paragraph
     - returns: Modified paragraph
     */
    internal static func _indent(paragraph: String) -> String {
        return fullWidthWhiteSpace + paragraph
    }

    /**
     Insert a space after some reserved marks.
     - parameter paragraph: Paragraph
     - returns: Modified paragraph
     */
    internal static func _insertSpace(paragraph: String) -> String {
        let replacementRule = [
            "！": "！　",
            "？": "？　",
            "!": "!　",
            "?": "?　",
            "‼": "‼　",
            "⁉": "⁉　",
            "⁈": "⁈　",
            "⁇": "⁇　"
        ]
        let ret = replacementRule.reduce(paragraph) {
            $0.replacingOccurrences(of: $1.key, with: $1.value)
        }
        return ret
    }

    /**
     Delete an unnecessary space around some reserved marks.
     - parameter paragraph: Paragraph
     - returns: Modified paragraph
     */
    internal static func _deleteUnnecessarySpace(paragraph: String) -> String {
        let replacementRule = [
            "　！": "！",
            "　？": "？",
            "　!": "!",
            "　?": "?",
            "　‼": "‼",
            "　⁉": "⁉",
            "　⁈": "⁈",
            "　⁇": "⁇",
            "　」": "」",
            "　』": "』",
            "　）": "）",
            "！　　": "！　",
            "？　　": "？　",
            "!　　": "!　",
            "?　　": "?　",
            "‼　　": "‼　",
            "⁉　　": "⁉　",
            "⁈　　": "⁈　",
            "⁇　　": "⁇　"
        ]
        let ret = replacementRule.reduce(paragraph) {
            $0.replacingOccurrences(of: $1.key, with: $1.value)
        }
        return ret
    }

    /**
     Delete an space before an opening bracket.
     - parameter paragraph: Paragraph
     - parameter considerDashes: Each dashed paragraph is considered as a dialog
     - returns: Modified paragraph
     */
    internal static func _deleteSpaceBeforeOpeningBracket(paragraph: String, considerDashes: Bool) -> String {
        let replacementRule = considerDashes ? [
            "　「": "「",
            "　『": "『",
            "　（": "（",
            "　―": "―"
        ] : [
            "　「": "「",
            "　『": "『",
            "　（": "（"
        ]
        let ret = replacementRule.reduce(paragraph) {
            $0.replacingOccurrences(of: $1.key, with: $1.value)
        }
        return ret
    }

    /**
     Delete a punctuation before a closing bracket.
     - parameter paragraph: Paragraph
     - returns: Modified paragraph
     */
    internal static func _deletePunctuationBeforeClosingBracket(paragraph: String) -> String {
        let replacementRule = [
            "、」": "」",
            "。」": "」",
            "、』": "』",
            "。』": "』",
            "、）": "）",
            "。）": "）"
        ]
        let ret = replacementRule.reduce(paragraph) {
            $0.replacingOccurrences(of: $1.key, with: $1.value)
        }
        return ret
    }

}
