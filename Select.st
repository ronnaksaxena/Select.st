" Select.st
  Alistair Campbell
  Spring 2018, Fall 2019 "

Object subclass: Select [
    | guardBlocks thenBlocks
      elseBlock
      switchValue
      allowedMsgs |


    "------------------------------------------------------------------------"
    " PRIVATE METHODS....."

    init [
        guardBlocks := Array new.
        thenBlocks := Array new.
        allowedMsgs := Set new.
        allowedMsgs addAll: #(#if:then: #end #else: #switch:)
    ]

    checkAllowed: msg [
        (allowedMsgs includes: msg) ifFalse: [
            ^self class errorNotAllowed: msg
        ]
    ]

    iff: booleanBlock thenn: thenBlock [
        " Save the condition and do blocks in the arrays.  This is a
         helper method for if:then: and case:then:"

        guardBlocks := guardBlocks, (Array with: booleanBlock).
        thenBlocks := thenBlocks, (Array with: thenBlock)
    ]


    "------------------------------------------------------------------------"
    " PUBLIC METHODS BELOW HERE....."

    switch: aValue [
        self checkAllowed: #switch:.
        allowedMsgs remove: #switch:.
        allowedMsgs remove: #if:then:.
        allowedMsgs add: #case:then:.
        switchValue := aValue.
    ]

    if: booleanBlock then: doBlock [
        self checkAllowed: #if:then:.
        allowedMsgs remove: #switch: ifAbsent: [].
        self iff: booleanBlock
             thenn: doBlock
    ]

    case: collectionBlock then: doBlock [
        self checkAllowed: #case:then:.
        self iff: [(collectionBlock value) includes: switchValue]
           thenn: doBlock
    ]

    else: aBlock [
        self checkAllowed: #else:.
        allowedMsgs remove: #if:then: ifAbsent: [].
        allowedMsgs remove: #case:then: ifAbsent: [].
        allowedMsgs remove: #else:.
        elseBlock := aBlock
    ]

    end [
       self checkAllowed: #end.
       allowedMsgs := #()
    ]

]

Select subclass: AllSelect [
    end [
    |foundTrue|
    foundTrue := false.
    "Does all true then blocks and then updates foundtrue upon finding one"
    1 to: guardBlocks size do: [ :i | ((guardBlocks at: i) value) ifTrue: [((thenBlocks at: i) value).
                                      foundTrue := true]].
    foundTrue ifFalse: [elseBlock value]
    ]
]

Select subclass: AnySelect [
    end [
    |lastTrueIdx|
    lastTrueIdx := 0.
    "Loops through guardblocks and outputs all correct thenblocks"
    1 to: guardBlocks size do: [:idx | ((guardBlocks at: idx) value) ifTrue: [
                                          lastTrueIdx := idx]].
    (lastTrueIdx>0) ifTrue: [((thenBlocks at: lastTrueIdx) value)]
                    ifFalse: [elseBlock value]
    ]
]

Select subclass: FirstSelect [
    end [
    "Only evaluates first true block"
    1 to: guardBlocks size do: [:idx | ((guardBlocks at: idx) value) ifTrue: [
                                         ^((thenBlocks at: idx) value)]].
    "checks if else is there or not"
    (elseBlock isNil) ifTrue: [^nil]
                      ifFalse: [^elseBlock value].
  ]

]

Select subclass: ExclusiveSelect [
    end [
    |numTrue trueIdx|
    trueIdx := 0.
    numTrue := 0.
    "Loops through guardBlocks to find number of true conditions"
    1 to: guardBlocks size do: [:idx | ((guardBlocks at: idx)value) ifTrue: [
    numTrue := numTrue+1.
    trueIdx := idx
    ].
    ].
    "checks which condition of exclusive select to output"
    numTrue=1 ifTrue: [((thenBlocks at: trueIdx)value)].
    numTrue=0 ifTrue: [elseBlock value].
    numTrue>1 ifTrue: ['Error signalled.' display]
    ]
]

Select class extend [
    notAllowedString: msg [
        |d|
        d := Dictionary new.
        d at: #end put: ' after end.'.
        d at: #else: put: ' after else: or end.'.
        d at: #case:then: put: ' before switch:, after else:, or after end.'.
        d at: #if:then: put: ' after switch, after else:, or after end.'.
        d at: #switch: put: ' after switch, if:then:, else:, or end.'.
        ^d at: msg
    ]

    errorNotAllowed: msg [^self error: msg asString,
                                       ' is not allowed',
                                       (self notAllowedString: msg)]

    all [ ^AllSelect new init ]

    any [ ^AnySelect new init ]

    exclusive [ ^ExclusiveSelect new init ]

    first [ ^FirstSelect new init ]
].
"
Select first if: [cout << 'one'; nl. 1=2] then: [cout << 'no'; nl];
             if: [cout << 'two'; nl. 1=1] then: [cout << 'yes'; nl];
             if: [cout << 'three'; nl. 1=1] then: [cout << 'affirm'; nl];
             end."
"TESTS:"
"[a := 2.
Select first
if: [a = 2] then: [Transcript show: 'one!'];
if: [a > 3] then: [Transcript show: 'positive!'];
if: [a = 4] then: [Transcript show: 'another one']
else: [Transcipt show: 'bet']
end] value"
"

[Select all switch: 5;
case: [1 to: 5] then: [Transcript show: '5 is in this collection'];
case: [Set with: 2] then: [Transcipt show: 'but not this one'];
case: [1 to: 9 by: 2] then: [Transcript show: 'could be!'];
else: [Transcipt show: 'definitely not'];
end] valse"
