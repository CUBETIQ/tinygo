target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "armv7m-none-eabi"

%runtime.typecodeID = type { %runtime.typecodeID*, i32, %runtime.interfaceMethodInfo* }
%runtime.interfaceMethodInfo = type { i8*, i32 }

@"reflect/types.type:basic:uint8" = private constant %runtime.typecodeID zeroinitializer
@"reflect/types.type:basic:int" = private constant %runtime.typecodeID zeroinitializer
@"reflect/types.type:named:Number" = private constant %runtime.typecodeID { %runtime.typecodeID* @"reflect/types.type:basic:int", i32 0, %runtime.interfaceMethodInfo* null }

declare void @runtime.printuint8(i8)

declare void @runtime.printint16(i16)

declare void @runtime.printint32(i32)

declare void @runtime.printptr(i32)

declare void @runtime.printnl()

declare void @runtime.nilPanic(i8*, i8*)

define void @printInterfaces() {
  call void @printInterface(i32 ptrtoint (%runtime.typecodeID* @"reflect/types.type:basic:int" to i32), i8* inttoptr (i32 5 to i8*))
  call void @printInterface(i32 ptrtoint (%runtime.typecodeID* @"reflect/types.type:basic:uint8" to i32), i8* inttoptr (i8 120 to i8*))
  call void @printInterface(i32 ptrtoint (%runtime.typecodeID* @"reflect/types.type:named:Number" to i32), i8* inttoptr (i32 3 to i8*))
  ret void
}

define void @printInterface(i32 %typecode, i8* %value) {
  %typeassert.ok1 = call i1 @"Unmatched$typeassert"(i32 %typecode)
  br i1 %typeassert.ok1, label %typeswitch.Unmatched, label %typeswitch.notUnmatched

typeswitch.Unmatched:                             ; preds = %0
  %unmatched = ptrtoint i8* %value to i32
  call void @runtime.printptr(i32 %unmatched)
  call void @runtime.printnl()
  ret void

typeswitch.notUnmatched:                          ; preds = %0
  %typeassert.ok = call i1 @"Doubler$typeassert"(i32 %typecode)
  br i1 %typeassert.ok, label %typeswitch.Doubler, label %typeswitch.notDoubler

typeswitch.Doubler:                               ; preds = %typeswitch.notUnmatched
  %1 = call i32 @"(Doubler).Double"(i8* %value, i8* null, i32 %typecode, i8* null)
  call void @runtime.printint32(i32 %1)
  ret void

typeswitch.notDoubler:                            ; preds = %typeswitch.notUnmatched
  %typeassert.ok2 = icmp eq i32 ptrtoint (%runtime.typecodeID* @"reflect/types.type:basic:uint8" to i32), %typecode
  br i1 %typeassert.ok2, label %typeswitch.byte, label %typeswitch.notByte

typeswitch.byte:                                  ; preds = %typeswitch.notDoubler
  %byte = ptrtoint i8* %value to i8
  call void @runtime.printuint8(i8 %byte)
  call void @runtime.printnl()
  ret void

typeswitch.notByte:                               ; preds = %typeswitch.notDoubler
  br i1 false, label %typeswitch.int16, label %typeswitch.notInt16

typeswitch.int16:                                 ; preds = %typeswitch.notByte
  %int16 = ptrtoint i8* %value to i16
  call void @runtime.printint16(i16 %int16)
  call void @runtime.printnl()
  ret void

typeswitch.notInt16:                              ; preds = %typeswitch.notByte
  ret void
}

define i32 @"(Number).Double"(i32 %receiver, i8* %parentHandle) {
  %ret = mul i32 %receiver, 2
  ret i32 %ret
}

define i32 @"(Number).Double$invoke"(i8* %receiverPtr, i8* %parentHandle) {
  %receiver = ptrtoint i8* %receiverPtr to i32
  %ret = call i32 @"(Number).Double"(i32 %receiver, i8* null)
  ret i32 %ret
}

define internal i32 @"(Doubler).Double"(i8* %0, i8* %1, i32 %actualType, i8* %parentHandle) unnamed_addr {
entry:
  %"named:Number.icmp" = icmp eq i32 %actualType, ptrtoint (%runtime.typecodeID* @"reflect/types.type:named:Number" to i32)
  br i1 %"named:Number.icmp", label %"named:Number", label %"named:Number.next"

"named:Number":                                   ; preds = %entry
  %2 = call i32 @"(Number).Double$invoke"(i8* %0, i8* %1)
  ret i32 %2

"named:Number.next":                              ; preds = %entry
  call void @runtime.nilPanic(i8* undef, i8* undef)
  unreachable
}

define internal i1 @"Doubler$typeassert"(i32 %actualType) unnamed_addr {
entry:
  %"named:Number.icmp" = icmp eq i32 %actualType, ptrtoint (%runtime.typecodeID* @"reflect/types.type:named:Number" to i32)
  br i1 %"named:Number.icmp", label %then, label %"named:Number.next"

then:                                             ; preds = %entry
  ret i1 true

"named:Number.next":                              ; preds = %entry
  ret i1 false
}

define internal i1 @"Unmatched$typeassert"(i32 %actualType) unnamed_addr {
entry:
  ret i1 false

then:                                             ; No predecessors!
  ret i1 true
}
