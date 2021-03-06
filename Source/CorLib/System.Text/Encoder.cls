VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Encoder"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'The MIT License (MIT)
'Copyright (c) 2017 Kelly Ethridge
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
' Module: Encoder
'

''
' Provides an interface for encoding unicode characters into bytes.
'
'@Folder("CorLib.System.Text")
Option Explicit


''
' Returns an <a href="EncoderFallback.html">EncoderFallback</a> object for the current <b>Encoder</b> object.
'
' @return The <a href="EncoderFallback.html">EncoderFallback</a> associated with the current <b>Encoder</b> object.
Public Property Get Fallback() As EncoderFallback: End Property

''
' Sets an <a href="EncoderFallback.html">EncoderFallback</a> object instance for the current <b>Encoder</b> object.
'
' @param Value The <a href="EncoderFallback.html">EncoderFallback</a> object to be associated with the current <b>Encoder</b> object.
Public Property Set Fallback(ByVal Value As EncoderFallback): End Property

''
' Return an <a href="EncoderFallbackBuffer.html">EncoderFallbackBuffer</a> object associated with current <b>Encoder</b> object.
'
' @return The <a href="EncoderFallbackBuffer.html">EncoderFallbackBuffer</a> object associated with the current <b>Encoder</b> object.
Public Property Get FallbackBuffer() As EncoderFallbackBuffer: End Property

''
' Returns the number of encoded bytes the set of characters would produce.
'
' @param Chars The set of characters that would be used to produce the encoded bytes.
' @param Index The first character in the array to begin the encoding count.
' @param Count The number of characters to be included in the encoding count.
' @param Flush <b>True</b> to simulate clearing the internal state of the encoder after the calculation; otherwise, <b>False</b>.
' @return The number of bytes produced by encoding the specified characters and any characters in the internal buffer.
' @remarks <p>This method does not affect the state of the encoder.</p>
' <p>To calculate the exact array size that <a href="Encoder.GetBytes.html">GetBytes</a> requires to store the resulting bytes, the application should use <b>GetByteCount</b>.</p>
' <p>If <a href="Encoder.GetBytes.html">GetBytes</a> is called with <i>Flush</i> set to <b>False</b>, the encoder stores trailing characters at the end of the data block in an
' internal buffer and uses them in the next encoding operation. The application should call <b>GetByteCount</b> on a block of data immediately
' before calling <a href="Encoder.GetBytes.html">GetBytes</a> on the same block, so that any trailing characters from the previous block are included in the calculation.</p>
Public Function GetByteCount(ByRef Chars() As Integer, ByVal Index As Long, ByVal Count As Long, ByVal Flush As Boolean) As Long: End Function

''
' Returns the encoded bytes generated from a set of unicode characters.
'
' @param Chars The unicode characters to be encoded.
' @param CharIndex The character to begin encoding at.
' @param CharCount The number of characters to be used in the encoding process.
' @param Bytes The encoded set of bytes produced from encoding <i>Chars</i>.
' @param ByteIndex The starting position in the array to place the encoded bytes.
' @param Flush Indicates if the Encoder should maintain state between calls.
' @return The number of bytes actually produced from the encoding.
'
Public Function GetBytes(ByRef Chars() As Integer, ByVal CharIndex As Long, ByVal CharCount As Long, ByRef Bytes() As Byte, ByVal ByteIndex As Long, ByVal Flush As Boolean) As Long: End Function

''
' Converts an array of Unicode characters to an encoded byte sequence and stores the result in an array of bytes.
'
' @param Chars An array of characters to be converted.
' @param CharIndex The starting position to be converting in the <i>Chars</i> array.
' @param CharCount The number of characters to be converted.
' @param Bytes An array to received the converted characters.
' @param ByteIndex The starting position to begin receiving converted characters.
' @param ByteCount The number of bytes in the received buffer to be used.
' @param Flush <b>True</b> if the characters have finished being converted; otherwise <b>False</b>.
' @param CharsUsed The number characters actually converted from the <i>Chars</i> array.
' @param BytesUsed The number bytes used for the encoding of the characters.
' @param Completed <b>True</b> if the specificed <i>CharCount</i> had been reached in the conversion; otherwise <b>False</b>.
Public Sub Convert(ByRef Chars() As Integer, ByVal CharIndex As Long, ByVal CharCount As Long, ByRef Bytes() As Byte, ByVal ByteIndex As Long, ByVal ByteCount As Long, ByVal Flush As Boolean, ByRef CharsUsed As Long, ByRef BytesUsed As Long, ByRef Completed As Boolean): End Sub

''
' Clears the internal state of the encoder.
'
Public Sub Reset(): End Sub

''
' Returns a string representation of this instance.
'
' @return A string that describes this object instance.
'
Public Function ToString() As String: End Function

''
' Used to determine if to objects are of equal value.
'
' @param value An object to be compared to this instance for equality.
' @return An indication of equality.
'
Public Function Equals(ByRef Value As Variant) As Boolean: End Function

''
' Returns a pseudo-unique number to identify this instance.
'
' @return A pseudo-unique number to identify this instance.
'
Public Function GetHashCode() As Long: End Function
