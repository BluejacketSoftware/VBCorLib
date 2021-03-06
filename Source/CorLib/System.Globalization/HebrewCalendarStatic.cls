VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "HebrewCalendarStatic"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'The MIT License (MIT)
'Copyright (c) 2018 Kelly Ethridge
'
'Permission is hereby granted, free of charge, to any person obtaining a copy
'of this software and associated documentation files (the "Software"), to deal
'in the Software without restriction, including without limitation the rights to
'use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
'the Software, and to permit persons to whom the Software is furnished to do so,
'subject to the following conditions:
'
'The above copyright notice and this permission notice shall be included in all
'copies or substantial portions of the Software.
'
'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
'INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
'PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
'FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
'OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
'DEALINGS IN THE SOFTWARE.
'
'
' Module: HebrewCalendarStatic
'

''
' Provides static methods for the <a href="HebrewCalendar.html">HebrewCalendar</a> class.
'
' @see HebrewCalendar
'
'@Folder("CorLib.System.Globalization")
Option Explicit

Private mMinSupportedDateTime As CorDateTime
Private mMaxSupportedDateTime As CorDateTime


''
' Returns the current era of the Hebrew calendar.
'
' @return Returns a constant of 1.
'
Public Property Get HebrewEra() As Long
    HebrewEra = 1
End Property

Friend Property Get MaxSupportedDateTime() As CorDateTime
    Set MaxSupportedDateTime = mMaxSupportedDateTime
End Property

Friend Property Get MinSupportedDateTime() As CorDateTime
    Set MinSupportedDateTime = mMinSupportedDateTime
End Property


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   Constructors
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Class_Initialize()
    Dim dt As CorDateTime
    Set dt = Cor.NewDateTime(2239, 9, 29, 23, 59, 59, 999)
    Set mMaxSupportedDateTime = CorDateTime.FromMilliseconds(dt.TotalMilliseconds + 0.9999@)
    Set mMinSupportedDateTime = Cor.NewDateTime(1583, 1, 1)
End Sub
