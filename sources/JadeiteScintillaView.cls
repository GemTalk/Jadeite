"Filed out from Dolphin Smalltalk 7"!

ScintillaView subclass: #JadeiteScintillaView
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteScintillaView guid: (GUID fromString: '{c5c93a92-0ad5-4000-9d17-7e9a577e2cdf}')!
JadeiteScintillaView comment: ''!
!JadeiteScintillaView categoriesForClass!MVP-Views! !
!JadeiteScintillaView methodsFor!

editFind
	"super implementation that just returns the dialog for testing"
	^self findPrompt: self suggestedFindText!

find: aFindDetails range: anInterval
	"Private - Find the first occurrence of text in the receiver that matches the specified
	<AdvancedFindDetails>, within the range, anInterval. Answer the <Interval> of the match (an
	empty interval if not found)."

	| text matchString matchLen start stop textLen |

	aFindDetails isRegularExpression
		ifTrue: [^self findRegularExpression: aFindDetails inRange: anInterval].
	textLen := self textLength.
	aFindDetails isForwards
		ifTrue: 
			[text := self plainText.
			matchString := aFindDetails pattern.
			start := anInterval start.
			stop := anInterval stop]
		ifFalse: 
			[text := self plainText reverse.
			matchString := aFindDetails pattern reverse.
			start := textLen - anInterval stop + 1.
			stop := textLen - anInterval start + 1].
	aFindDetails isCaseSensitive
		ifFalse: 
			[text := text asLowercase.
			matchString := matchString asLowercase].
	matchLen := matchString size.
	start to: stop - matchLen + 1
		do: 
			[:pos |
			(self
				searchFor: matchString
				in: text
				from: pos
				length: matchLen
				details: aFindDetails)
					ifTrue: 
						["Possible match - check for whole word if necessary."
						(aFindDetails isWholeWord not or: 
								[aFindDetails isWholeWord and: 
										[(pos > 1 and: [(text at: pos - 1) isAlphaNumeric not])
											and: [pos + matchLen < textLen and: [(text at: pos + matchLen) isAlphaNumeric not]]]])
							ifTrue: 
								[| first |
								first := aFindDetails isForwards ifTrue: [pos] ifFalse: [textLen - pos + 1 - matchLen + 1].
								^first to: first + matchLen - 1]]].
	^0 to: -1!

findDialogClass
	^Smalltalk at: #JadeiteAdvancedFindDialog ifAbsent: [FindDialog]!

searchFor: matchString in: text from: pos length: matchLen details: findDetails
	^findDetails isWildcard
		ifTrue: [matchString match: (text midString: matchLen from: pos) ignoreCase: findDetails isCaseSensitive not]
		ifFalse: [matchString = (text midString: matchLen from: pos)]! !
!JadeiteScintillaView categoriesFor: #editFind!constants!private! !
!JadeiteScintillaView categoriesFor: #find:range:!private!searching & replacing! !
!JadeiteScintillaView categoriesFor: #findDialogClass!constants!private! !
!JadeiteScintillaView categoriesFor: #searchFor:in:from:length:details:!private!searching & replacing! !

