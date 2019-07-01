Postfix: A:=DC*BE/+

======Quadruples Notation======
  *,  D,  C, T1,
  /,  B,  E, T2,
  +, T1, T2,  A,

======Assembly======
LDA   D
MUL   C
STO  T1
LDA   B
DIV   E
STO  T2
LDA  T1
ADD  T2
STO   A
