"Filed out from Dolphin Smallalk"!

ScintillaView subclass: #JadeiteScintillaView
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteScintillaView guid: (GUID fromString: '{c5c93a92-0ad5-4000-9d17-7e9a577e2cdf}')!
JadeiteScintillaView comment: ''!
!JadeiteScintillaView categoriesForClass!MVP-Views! !
!JadeiteScintillaView methodsFor!

editCopy
	self copySelection!

editCut
	self cutSelection!

editDelete
	self clearSelection!

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

onViewCreated
	super onViewCreated.
	JadeitePreferences current
		ifNotNil: 
			[self font: JadeitePreferences current currentTextFont	"Avoid failure during window creation right after login, we'll set font in post login"]!

onViewOpened
	"must set the stringClass here because when Dolphin opens a view, #initialize is NOT run. 
	#basicNew is sent. But even sending an #initialize after #basicNew won't work because 
	Dolphin does some weird restore from proxy code to open the view which *retains the 
	state of the proxy* and ignores the initialized changes to the newly created object.
	See STBViewProxy>>restoreView for the culprit"

	super onViewOpened.
	stringClass := Utf8String!

queryCommand: query
	"for some reason, TextEdit does not query #redo"

	(#(#redo) includes: query command)
		ifTrue: 
			[query isEnabled: self canRedo.
			^true].
	(#(#editCut #editCopy) includes: query command)
		ifTrue: 
			[query isEnabled: self hasSelection.
			^true].
	#editDelete == query command
		ifTrue: [query isEnabled: (self model isNil not and: [self model value notNil])].
	^super queryCommand: query!

searchFor: matchString in: text from: pos length: matchLen details: findDetails
	^findDetails isWildcard
		ifTrue: [matchString match: (text midString: matchLen from: pos) ignoreCase: findDetails isCaseSensitive not]
		ifFalse: [matchString = (text midString: matchLen from: pos)]! !
!JadeiteScintillaView categoriesForMethods!
editCopy!constants!private! !
editCut!constants!private! !
editDelete!constants!private! !
editFind!constants!private! !
find:range:!private!searching & replacing! !
findDialogClass!constants!private! !
onViewCreated!event handlers!public! !
onViewOpened!event handlers!public! !
queryCommand:!menu handlers support!public! !
searchFor:in:from:length:details:!private!searching & replacing! !
!

