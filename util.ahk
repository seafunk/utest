getFile(name){
static files := {}
if files[name]
  Return files[name]
file := {}
loop, read, %name%
{
file[A_Index] := A_LoopReadLine
}
files[name] := file
return file
}


getLinesNear(lineNumber, filename){
if lineNumber is not number
  throw exception("lineNumber not provided")
file := getFile(filename)
lines := ""
loop, 5{
lines .= file[lineNumber - 3 + A_Index] . "`n"
}
return lines
}
