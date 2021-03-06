VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "EncodingTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'
' EncodingTests
'
Option Explicit
Implements ICategorizable
Implements ITestCaseSource

Private Sub ICategorizable_Categorize(ByVal Cat As SimplyVBComp.CategoryCollector)
    Cat.ForFixture "System.Text"
End Sub

Private Sub ITestCaseSource_GetTestCases(ByVal Test As SimplyVBComp.TestCaseCollector)
    Select Case Test.MethodName
        Case "GetEncoding_WithCodePage_ReturnsCommonEncoding"
            Test.Use 1200, Encoding.Unicode
            Test.Use 1201, Encoding.BigEndianUnicode
            Test.Use 65000, Encoding.UTF7
            Test.Use 65001, Encoding.UTF8
            Test.Use 20127, Encoding.ASCII
            Test.Use 0, Encoding.Default
            Test.Use 12000, Encoding.UTF32
            
        Case "GetEncoding_WithEncodingName_ReturnsCommonEncoding"
            Test.Use "unicode", Encoding.Unicode
            Test.Use "utf-8", Encoding.UTF8
            Test.Use "us-ascii", Encoding.ASCII
            Test.Use "utf-7", Encoding.UTF7
            Test.Use "utf-32", Encoding.UTF32
            Test.Use "ascii", Encoding.ASCII
            
    End Select
End Sub

Public Sub GetEncoding_WithLatin5_ReturnsEncoding28599()
    Dim Actual As Encoding
    
    Set Actual = Encoding.GetEncoding("latin5")
    
    Assert.That Actual.CodePage, Iz.EqualTo(28599)
    Assert.That Actual.WebName, Iz.EqualTo("iso-8859-9")
End Sub

Public Sub Unicode_WhenCalled_ReturnsLittleEndianUnicodeEncoding()
    Dim Actual As Encoding
    
    Set Actual = Encoding.Unicode
    
    Assert.That TypeOf Actual Is UnicodeEncoding, Iz.True
    Assert.That Actual.GetPreamble, Iz.EqualTo(NewBytes(&HFF, &HFE))
End Sub

Public Sub BigEndianUnicode_WhenCalled_ReturnsBigEndianUnicodeEncoding()
    Dim Actual As Encoding
    
    Set Actual = Encoding.BigEndianUnicode
    
    Assert.That TypeOf Actual Is UnicodeEncoding, Iz.True
    Assert.That Actual.GetPreamble, Iz.EqualTo(NewBytes(&HFE, &HFF))
End Sub

Public Sub GetEncoding_WithCodePage_ReturnsCommonEncoding(ByVal CodePage As Long, ByVal Expected As Encoding)
    Dim Actual As Encoding
    
    Set Actual = Encoding.GetEncoding(CodePage)
    
    Assert.That Actual, Iz.SameAs(Expected)
End Sub

Public Sub GetEncoding_WithEncodingName_ReturnsCommonEncoding(ByVal Name As String, ByVal Expected As Encoding)
    Dim Actual As Encoding
    
    Set Actual = Encoding.GetEncoding(Name)
    
    Assert.That Actual, Iz.SameAs(Expected)
End Sub

Public Sub UTF32_WhenCalled_ReturnsUTF32EncodingInLittleEndian()
    Dim Actual As Encoding
    
    Set Actual = Encoding.UTF32
    
    Assert.That TypeOf Actual Is UTF32Encoding, Iz.True
    Assert.That Actual.CodePage, Iz.EqualTo(12000)
End Sub

Public Sub GetEncoding_WithUTF32BigEndianName_ReturnsUTF32EncodingInBigEndian()
    Dim Actual As Encoding
    
    Set Actual = Encoding.GetEncoding("utf-32be")
    
    Assert.That TypeOf Actual Is UTF32Encoding, Iz.True
    Assert.That Actual.CodePage, Iz.EqualTo(12001)
End Sub

Public Sub GetEncodings_WhenCalled_ReturnsCachedVersion()
    Dim Infos1() As EncodingInfo
    Dim Infos2() As EncodingInfo
    
    Infos1 = Encoding.GetEncodings
    Infos2 = Encoding.GetEncodings
    
    Assert.That Infos1(0), Iz.Not.Nothing
    Assert.That Infos1(0), Iz.SameAs(Infos2(0))
End Sub

Public Sub WebName_WhenCalled_ReturnsInfoName()
    Dim Infos() As EncodingInfo
    Dim Enc As Encoding
    
    Infos = Encoding.GetEncodings
    Set Enc = Infos(0).GetEncoding
    
    Assert.That Enc.WebName, Iz.EqualTo(Infos(0).Name)
End Sub

Public Sub EncodingName_WhenCalled_ReturnsInfoDisplayName()
    Dim Infos() As EncodingInfo
    Dim Enc As Encoding
    
    Infos = Encoding.GetEncodings
    Set Enc = Infos(0).GetEncoding
    
    Assert.That Enc.EncodingName, Iz.EqualTo(Infos(0).DisplayName)
End Sub

