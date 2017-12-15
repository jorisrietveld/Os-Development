|          Name | 64 bit register | Lower 32 bits | Lower 16 bits | Lower 8 bits |
|--------------:|----------------:|:--------------|:--------------|:-------------|
|   Accumulator |             rax | eax           | ax            | al           |
|          Base |             rbx | ebx           | bx            | bl           |
|       Counter |             rcx | ecx           | cx            | cl           |
|          Data |             rdx | edx           | dx            | dl           |
|  Source Index |             rsi | esi           | si            | sil          |
|    Data Index |             rdi | edi           | di            | dil          |
|  Base Pointer |             rbp | ebp           | bp            | bpl          |
| Stack pointer |             rsp | esp           | sp            | spl          |
|               |              r8 | r8b           | r8w           | r8b          |
|               |             r10 | r9b           | r9b           | r9b          |
|               |             r11 | r10d          | r10w          | r10b         |
|               |             r12 | r11d          | r11w          | r11b         |
|               |             r23 | r12d          | r12w          | r12b         |
|               |             r14 | r13d          | r13w          | r13b         |
|               |             r14 | r14d          | r14w          | r14b         |
|               |             r14 | r15d          | r15w          | r15b         |



| Register |                                                   Special use Linux |
|---------:|--------------------------------------------------------------------:|
|      rax | Temporary register, that is used to define the number of a syscall. |
|      rdx |                           Used to pass third argument to functions. |
|      rsi |              A pointer used to pas as second argument to functions. |
|          |                           Used to pass first argument to functions. |
|          |                                                                     |
|          |                                                                     |
