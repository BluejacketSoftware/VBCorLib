VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CryptoAPI"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'The MIT License (MIT)
'Copyright (c) 2012 Kelly Ethridge
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
' Module: CryptoAPI
'

''
' A simple wrapper around the Crypto API functions.
'
'@Folder("CorLib.System.Security.Cryptography")
Option Explicit
Private Declare Function CryptEnumProvidersA Lib "advapi32.dll" (ByVal dwIndex As Long, ByVal pdwReserved As Long, ByVal dwFlags As Long, ByRef pdwProvType As Long, ByVal pszProvName As String, ByRef pcbProvName As Long) As Long

Private Type BLOBHEADER
    bType       As Byte
    bVersion    As Byte
    reserved    As Integer
    aiKeyAlg    As Long
End Type

Private Type SIMPLEBLOB512
    Header                  As BLOBHEADER
    DecryptAlgId            As Long
    EncryptedKey(0 To 63)   As Byte
End Type

Private Type PROV_ENUMALGS
    aiAlgid     As Long
    dwBitLen    As Long
    dwNameLen   As Long
    szName      As String * 20
End Type

Private mRSAProviderName    As String
Private mDSAProviderName    As String
Private mHasHighEncryption  As Boolean
Private mDefaultProvider    As Long
Private mExponentOfOneKey   As Long


''
' This is the default provider for this application instance that most ciphers will use.
'
Friend Property Get DefaultProvider() As Long
    If mDefaultProvider = vbNullPtr Then
        mDefaultProvider = AcquireRSAContext
    End If
    
    DefaultProvider = mDefaultProvider
End Property

''
' Acquires an RSA specific context from a provider.
'
Friend Function AcquireRSAContext(Optional ByRef ContainerName As String, Optional ByRef ProviderName As String, Optional ByVal Flags As Long) As Long
    AcquireRSAContext = AcquireContext(ContainerName, ProviderName, PROV_RSA_AES, Flags)
End Function

''
' Acquires a DSA specific context from a provider.
'
Friend Function AcquireDSAContext(Optional ByRef ContainerName As String, Optional ByRef ProviderName As String, Optional ByRef ProviderType As Long, Optional ByVal Flags As Long) As Long
    If Len(ProviderName) = 0 Then
        ProviderName = mDSAProviderName
    End If
    If ProviderType = 0 Then
        ProviderType = PROV_DSS_DH
    End If
    AcquireDSAContext = AcquireContext(ContainerName, ProviderName, ProviderType, Flags)
End Function

''
' Returns if this machine supports high-end encryption.
'
Friend Property Get HasHighEncryption() As Boolean
    HasHighEncryption = mHasHighEncryption
End Property

''
' Acquires a context with the specified container.
'
' @remarks If the container does not exist, it will be created.
'
Friend Function AcquireContext(Optional ByRef ContainerName As String, Optional ByRef ProviderName As String, Optional ByRef ProviderType As Long, Optional ByVal Flags As Long) As Long
    If ProviderType = 0 Then
        ProviderType = PROV_RSA_AES
    End If
    
    If Len(ContainerName) = 0 Then
        ContainerName = CorString.Format("COR_{0}", Guid.NewGuid)
    End If
    
    If CryptAcquireContext(AcquireContext, ContainerName, ProviderName, ProviderType, Flags) = BOOL_FALSE Then
        If Err.LastDllError = NTE_BAD_KEYSET Then
            If CryptAcquireContext(AcquireContext, ContainerName, ProviderName, ProviderType, Flags Or CRYPT_NEWKEYSET) = BOOL_FALSE Then
                CryptoError
            End If
        Else
            CryptoError
        End If
    End If
End Function

''
' Releases an existing context with the option to delete all keys contained in the associated key container.
'
Friend Sub ReleaseContext(ByVal Provider As Long, Optional ByVal DeleteKeySet As Boolean = False)
    If Provider = vbNullPtr Then
        Exit Sub
    End If
    
    Dim ContainerName   As String
    Dim ProviderType    As Long
    
    If DeleteKeySet Then
        ContainerName = GetProvParamString(Provider, PP_CONTAINER)
        ProviderType = GetProvParamLong(Provider, PP_PROVTYPE)
    End If
    
    If CryptReleaseContext(Provider, 0) = BOOL_FALSE Then
        CryptoError
    End If
    
    If DeleteKeySet Then
        CryptAcquireContext Provider, ContainerName, vbNullString, ProviderType, CRYPT_DELETEKEYSET
    End If
End Sub

''
' Imports a plain text key into the CryptoAPI.
'
Friend Function ImportPlainTextKey(ByVal Provider As Long, ByVal AlgId As Long, ByRef RgbKey() As Byte, Optional ByVal UseSalt As Boolean) As Long
    If mExponentOfOneKey = vbNullPtr Then
        CreateExponentOfOneKey
    End If
    
    Dim Flags As Long
    If Not UseSalt Then
        Flags = CRYPT_NO_SALT
    End If
    
    Dim Blob As SIMPLEBLOB512
    Blob = CreateSessionBlob(AlgId, RgbKey)
    
    If CryptImportKey(Provider, Blob, Len(Blob), mExponentOfOneKey, Flags, ImportPlainTextKey) = BOOL_FALSE Then
        CryptoError
    End If
End Function

''
' Destroys an existing key.
'
Friend Sub DestroyKey(ByVal Key As Long)
    If Key <> vbNullPtr Then
        If CryptDestroyKey(Key) = BOOL_FALSE Then
            CryptoError
        End If
    End If
End Sub

''
' Returns a numeric parameter from the specified provider.
'
Friend Function GetProvParamLong(ByVal Provider As Long, ByVal Param As Long, Optional ByVal Flags As Long) As Long
    If CryptGetProvParam(Provider, Param, GetProvParamLong, 4, Flags) = BOOL_FALSE Then
        CryptoError
    End If
End Function

''
' Returns a string parameter from the specified provider.
'
Friend Function GetProvParamString(ByVal Provider As Long, ByVal Param As Long, Optional ByVal Flags As Long) As String
    Dim Size As Long
    If CryptGetProvParam(Provider, Param, ByVal 0&, Size, Flags) = BOOL_FALSE Then
        CryptoError
    End If
    
    Dim Bytes() As Byte
    ReDim Bytes(0 To Size - 1)
    
    If CryptGetProvParam(Provider, Param, Bytes(0), Size, Flags) = BOOL_FALSE Then
        CryptoError
    End If
        
    GetProvParamString = Left$(StrConv(Bytes, vbUnicode), Size - 1)
End Function

''
' Returns a numeric parameter from the speicified key.
'
Friend Function GetKeyParamLong(ByVal Key As Long, ByVal Param As Long, Optional ByVal Flags As Long) As Long
    If CryptGetKeyParam(Key, Param, GetKeyParamLong, 4, Flags) = BOOL_FALSE Then
        CryptoError
    End If
End Function

''
' Returns a string parameter from the specified key.
'
Friend Function GetKeyParamString(ByVal Key As Long, ByVal Param As Long, Optional ByVal Flags As Long) As String
    Dim Size As Long
    If CryptGetKeyParam(Key, Param, ByVal 0&, Size, Flags) = BOOL_FALSE Then
        CryptoError
    End If
    
    Dim Bytes() As Byte
    ReDim Bytes(0 To Size - 1)
    
    If CryptGetKeyParam(Key, Param, Bytes(0), Size, Flags) = BOOL_FALSE Then
        CryptoError
    End If
    
    GetKeyParamString = Left$(StrConv(Bytes, vbUnicode), Size - 1)
End Function

Friend Sub SetKeyParam(ByVal Key As Long, ByVal Param As Long, ByRef Value As Variant, Optional ByVal Flags As Long)
    Select Case VarType(Value)
        Case vbByteArray
            Dim bPtr As Long
            bPtr = MemLong(SAPtrV(Value) + PVDATA_OFFSET)
            If CryptSetKeyParam(Key, Param, ByVal bPtr, Flags) = BOOL_FALSE Then
                CryptoError
            End If
        Case vbLong, vbInteger, vbByte
            If CryptSetKeyParam(Key, Param, CLng(Value), Flags) = BOOL_FALSE Then
                CryptoError
            End If
        Case Else
            Throw Cor.NewNotSupportedException(CorString.Format("Key param type '{0}' not supported.", TypeName(Value)))
    End Select
End Sub

''
' Checks if the specified provider supports the specified algorithm.
'
Friend Function SupportsAlgorithm(ByVal Provider As Long, ByVal AlgId As Long) As Boolean
    Dim Flags As Long
    Flags = CRYPT_FIRST
    
    Dim Alg As PROV_ENUMALGS
    Do While CryptGetProvParam(Provider, PP_ENUMALGS, Alg, Len(Alg), Flags) <> BOOL_FALSE
        If Alg.aiAlgid = AlgId Then
            SupportsAlgorithm = True
            Exit Function
        End If
        Flags = 0
    Loop
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   Helpers
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub CryptoError()
    Throw Cor.NewCryptographicException(GetMessage(Err.LastDllError))
End Sub

''
' This enumerates all of the available cryptography providers
' in search for the most enhanced versions.
'
Private Sub DetermineProviderSupport()
    Dim Index   As Long
    Dim Name    As String
    Dim Size    As Long
    
    Size = 512
    Name = String$(Size, 0)
    
    Do While CryptEnumProvidersA(Index, 0, 0, 0&, Name, Size) <> 0
        
        ' We search for both the best RSA and DSS (DSA) providers.
        Select Case Left$(Name, Size - 1)
            Case MS_DEF_PROV
                ' We set the base provider if none has been set.
                If Len(mRSAProviderName) = 0 Then
                    mRSAProviderName = MS_DEF_PROV
                End If
            
            Case MS_ENHANCED_PROV
                ' We set the enhanced provider if no other
                ' high encryption has been found yet.
                If Not mHasHighEncryption Then
                    mRSAProviderName = MS_ENHANCED_PROV
                    mHasHighEncryption = True
                End If
                
            Case MS_ENH_RSA_AES_PROV
                ' We always prefer this provider.
                mRSAProviderName = MS_ENH_RSA_AES_PROV
                mHasHighEncryption = True
                
            Case MS_ENH_RSA_AES_PROV_XP
                ' This provider was named differently on XP.
                mRSAProviderName = MS_ENH_RSA_AES_PROV_XP
                mHasHighEncryption = True
                
            Case MS_DEF_DSS_DH_PROV
                ' We only set the default DSS provider if
                ' no other provider has been found yet.
                If Len(mDSAProviderName) = 0 Then
                    mDSAProviderName = MS_DEF_DSS_DH_PROV
                End If
                
            Case MS_ENH_DSS_DH_PROV
                ' We always prefer this provider.
                mDSAProviderName = MS_ENH_DSS_DH_PROV
                
        End Select
        
        Size = 512
        Index = Index + 1
    Loop
End Sub

''
' The CryptoAPI provides no standard method for importing keys
' with plain text values, so Micorsoft has created a work-around.
' This function is derived from the Microsoft solution.
'
' https://support.microsoft.com/en-us/kb/228786
'
Private Sub CreateExponentOfOneKey()
    Dim Csp As RSACryptoServiceProvider
    Set Csp = Cor.NewRSACryptoServiceProvider(512)
    
    Dim Params As RSAParameters
    Set Params = Csp.ExportParameters(True)
    
    Dim One() As Byte
    ReDim One(0 To UBound(Params.Exponent))
    One(UBound(One)) = 1
    Params.Exponent = One
    
    ReDim One(0 To UBound(Params.DP))
    One(UBound(One)) = 1
    Params.DP = One
    Params.DQ = One
    
    ReDim One(0 To UBound(Params.d))
    One(UBound(One)) = 1
    Params.d = One
    
    Dim Blob() As Byte
    Blob = Params.ToCspBlob(AT_KEYEXCHANGE)
    
    If CryptImportKey(mDefaultProvider, Blob(0), CorArray.Length(Blob), 0, CRYPT_EXPORTABLE, mExponentOfOneKey) = BOOL_FALSE Then
        CryptoError
    End If
End Sub

''
' Create a SIMPLEBLOB structure for key importing.
'
' https://support.microsoft.com/en-us/kb/228786
'
Private Function CreateSessionBlob(ByVal AlgId As Long, ByRef RgbKey() As Byte) As SIMPLEBLOB512
    With CreateSessionBlob
        ' Fill the BLOBHEADER portion
        With .Header
            .bType = SIMPLEBLOB
            .bVersion = 2
            .aiKeyAlg = AlgId
        End With
        
        ' Set the algorithm used to encrypt the following key.
        .DecryptAlgId = CALG_RSA_KEYX
        
        Dim ub As Long
        ub = UBound(RgbKey)
        
        ' Place the plain text key into the SIMPLEBLOB structure backwards.
        Dim i As Long
        For i = 0 To ub
            .EncryptedKey(i) = RgbKey(ub - i)
        Next i
        
        ' The first byte following the key is to remain a zero, but
        ' we fill the rest of the remaining bytes with random data, but
        ' only up through index 61. That leaves a size of 62 (0-61) bytes
        ' that can be filled up. Deduct the key size and the extra zero byte.
        Dim Bytes() As Byte
        Bytes = CryptoHelper.GetNonZeroRandomBytes(60 - ub)
        CopyMemory .EncryptedKey(ub + 2), Bytes(0), 60 - ub
        
        .EncryptedKey(62) = 2
    End With
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   Constructors
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Class_Initialize()
    DetermineProviderSupport
End Sub

Private Sub Class_Terminate()
    If mExponentOfOneKey <> vbNullPtr Then
        CryptDestroyKey mExponentOfOneKey
    End If
    If mDefaultProvider <> vbNullPtr Then
        ReleaseContext mDefaultProvider, True
    End If
End Sub
