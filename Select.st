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
        self iff: [ "MISSING" ]
             thenn: doBlock
    ]

    case: collectionBlock then: doBlock [
        self checkAllowed: #case:then:.
        self iff: [ "MISSING" ]
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
    end [ "MISSING" ]
]

Select subclass: AnySelect [
    end [ "MISSING" ]
]

Select subclass: FirstSelect [
    end [ "MISSING" ]
]

Select subclass: ExclusiveSelect [
    end [ "MISSING" ]
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
]
