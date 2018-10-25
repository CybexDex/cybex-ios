//
//  FontInfo.swift
//  SwiftRichString
//
//  Created by Daniele Margutti on 19/05/2018.
//  Copyright © 2018 SwiftRichString. All rights reserved.
//

import Foundation
import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif

internal let TVOS_SYSTEMFONT_SIZE: CGFloat = 29.0
internal let WATCHOS_SYSTEMFONT_SIZE: CGFloat = 12.0

/// FontInfo is an internal struct which describe the inner attributes related to a font instance.
/// User don't interact with this object directly but via `Style`'s properties.
/// Using the `attributes` property this object return a valid instance of the attributes to describe
/// required behaviour.
public class FontData {
	
	private static var DefaultFont = Font.systemFont(ofSize: 12.0)
	
	/// Font object
	var font: FontConvertible? { didSet { self.style?.invalidateCache() } }
	
	/// Size of the font
	var size: CGFloat? { didSet { self.style?.invalidateCache() } }
	
	#if os(OSX) || os(iOS) || os(tvOS)
	
	/// Configuration for the number case, also known as "figure style".
	var numberCase: NumberCase? { didSet { self.style?.invalidateCache() } }
	
	/// Configuration for number spacing, also known as "figure spacing".
	var numberSpacing: NumberSpacing? { didSet { self.style?.invalidateCache() } }
	
	/// Configuration for displyaing a fraction.
	var fractions: Fractions? { didSet { self.style?.invalidateCache() } }
	
	/// Superscript (superior) glpyh variants are used, as in footnotes¹.
	var superscript: Bool? { didSet { self.style?.invalidateCache() } }
	
	/// Subscript (inferior) glyph variants are used: vₑ.
	var `subscript`: Bool? { didSet { self.style?.invalidateCache() } }
	
	/// Ordinal glyph variants are used, as in the common typesetting of 4th.
	var ordinals: Bool? { didSet { self.style?.invalidateCache() } }
	
	/// Scientific inferior glyph variants are used: H₂O
	var scientificInferiors: Bool? { didSet { self.style?.invalidateCache() } }
	
	/// Configure small caps behavior.
	/// `fromUppercase` and `fromLowercase` can be combined: they are not mutually exclusive.
	var smallCaps: Set<SmallCaps> = [] { didSet { self.style?.invalidateCache() } }
	
	/// Different stylistic alternates available for customizing a font.
	var stylisticAlternates: StylisticAlternates = StylisticAlternates() { didSet { self.style?.invalidateCache() } }
	
	/// Different contextual alternates available for customizing a font.
	var contextualAlternates: ContextualAlternates = ContextualAlternates() { didSet { self.style?.invalidateCache() } }
	
	/// Describe trait variants to apply to the font.
	var traitVariants: TraitVariant? { didSet { self.style?.invalidateCache() } }
	
	/// Tracking to apply.
	var kerning: Kerning? { didSet { self.style?.invalidateCache() } }
	
	#endif
	
	/// Reference to parent style (used to invalidate cache; we can do better).
	weak var style: Style?
	
	/// Initialize a new `FontInfo` instance with system font with system font size.
	init() {
		self.font = nil
		self.size = nil
		/*#if os(tvOS)
		self.font = Font.systemFont(ofSize: TVOS_SYSTEMFONT_SIZE)
		self.size = TVOS_SYSTEMFONT_SIZE
		#elseif os(watchOS)
		self.font = Font.systemFont(ofSize: WATCHOS_SYSTEMFONT_SIZE)
		self.size = WATCHOS_SYSTEMFONT_SIZE
		#else
		self.font = Font.systemFont(ofSize: Font.systemFontSize)
		self.size = Font.systemFontSize
		#endif*/
	}
	
	/// Has font explicit value for font name or size
	var explicitFont: Bool {
		return (self.font != nil || self.size != nil)
	}
	
	/// Return a font with all attributes set.
	///
	/// - Parameter size: ignored. It will be overriden by `fontSize` property.
	/// - Returns: instance of the font
	var attributes: [NSAttributedString.Key:Any] {
		guard !self.explicitFont else {
			return [:]
		}
		return attributes(currentFont: self.font, size: self.size)
	}
	
	/// Apply font attributes to the selected range.
	/// It's used to support ineriths from current font of an attributed string.
	/// Note: this method does nothing if a fixed font is set because the entire font attributes are replaced
	/// by default's `.attributes` of the Style.
	///
	/// - Parameters:
	///   - source: source of the attributed string.
	///   - range: range of application, `nil` means the entire string.
	internal func addAttributes(to source: AttributedString, range: NSRange?) {
		// This method does nothing if a fixed value for font attributes is set.
		// This becuause font attributes will be set along with the remaining attributes from `.attributes` dictionary.
		guard self.explicitFont else {
			return
		}
		
		/// Enumerate fonts in string and attach the attributes
		let scanRange = (range ?? NSMakeRange(0, source.length))
		source.enumerateAttribute(.font, in: scanRange, options: []) { (fontValue, fontRange, shouldStop) in
			let currentFont = ((fontValue ?? FontData.DefaultFont) as? FontConvertible)
			let currentSize = (fontValue as? Font)?.pointSize
			let fontAttributes = self.attributes(currentFont: currentFont, size: currentSize)
			source.addAttributes(fontAttributes, range: fontRange)
		}
	}
	
	/// Return the attributes by sending an already set font/size.
	/// If no fixed font/size is already set on self the current font/size is used instead, along with the additional font attributes.
	///
	/// - Parameters:
	///   - currentFont: current font.
	///   - currentSize: current font size.
	/// - Returns: attributes
	public func attributes(currentFont: FontConvertible?, size currentSize: CGFloat?) -> [NSAttributedString.Key:Any] {
		var finalAttributes: [NSAttributedString.Key:Any] = [:]

		// generate an initial font from passed FontConvertible instance
		guard let size = (self.size ?? currentSize) else { return [:] }
		guard var finalFont = (self.font ?? currentFont)?.font(size: size) else { return [:] }
		
		// compose the attributes
		#if os(iOS) || os(tvOS) || os(OSX)
		var attributes: [FontInfoAttribute] = []

		attributes += [self.numberCase].compactMap { $0 }
		attributes += [self.fractions].compactMap { $0 }
		attributes += [self.superscript].compactMap { $0 }.map { ($0 == true ? VerticalPosition.superscript : VerticalPosition.normal) } as [FontInfoAttribute]
		attributes += [self.subscript].compactMap { $0 }.map { ($0 ? VerticalPosition.`subscript` : VerticalPosition.normal) } as [FontInfoAttribute]
		attributes += [self.ordinals].compactMap { $0 }.map { $0 ? VerticalPosition.ordinals : VerticalPosition.normal } as [FontInfoAttribute]
		attributes += [self.scientificInferiors].compactMap { $0 }.map { $0 ? VerticalPosition.scientificInferiors : VerticalPosition.normal } as [FontInfoAttribute]
		attributes += self.smallCaps.map { $0 as FontInfoAttribute }
		attributes += [self.stylisticAlternates as FontInfoAttribute]
		attributes += [self.contextualAlternates as FontInfoAttribute]
		
		finalFont = finalFont.withAttributes(attributes)
		
		if let traitVariants = self.traitVariants { // manage emphasis
			let descriptor = finalFont.fontDescriptor
			let existingTraits = descriptor.symbolicTraits
			let newTraits = existingTraits.union(traitVariants.symbolicTraits)
			
			// Explicit cast to optional because withSymbolicTraits returns an
			// optional on Mac, but not on iOS.
			let newDescriptor: FontDescriptor? = descriptor.withSymbolicTraits(newTraits)
			if let newDesciptor = newDescriptor {
				#if os(OSX)
				finalFont = Font(descriptor: newDesciptor, size: 0)!
				#else
				finalFont = Font(descriptor: newDesciptor, size: 0)
				#endif
			}
		}
		
		if let tracking = self.kerning { // manage kerning attributes
			finalAttributes[.kern] = tracking.kerning(for: finalFont)
		}
		#endif
		
		finalAttributes[.font] = finalFont // assign composed font
		return finalAttributes
	}
	
}
