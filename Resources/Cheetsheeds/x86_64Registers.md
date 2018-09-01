# An cheatsheed for rembering the X86-64 registers

### GPR General Purpose Registers - 16 bit



| **Register** |                   **Name** |                                                                    **Description** |
|-------------:|---------------------------:|-----------------------------------------------------------------------------------:|
|           AX |       Accumilator Register |                                                     Used in arithmetic operations. |
|           CX |           Counter Register |                                       Used in shift/rotate instructions and loops. |
|           DX |              Data Register |                                  Used in arithmetic oparations and I/O operations. |
|           BX |              Base Register | Used as a pointer to data (located in segment regiser DS, when in segmented mode). |
|           SP |     Stack Pointer Register |                                                   Pointer to the top of the stack. |
|           SB | Stack Base Pointer Regiser |                                                  Pointer to the base of the stack. |
|           SI |      Source Index Register |                                Used as a pointer to a source in stream operations. |
|           DI | Destination Index Register |                           Used as a pointer to a destination in stream operations. |

### The register build up
_This table shows the names of the registers and how they are build up. notice that the 16 bit register
is build up from 2 registers each 1 byte long. They are the registers with the H and L surfix_

<table>
    <tr>
        <th>32 bit</th>
        <th>16 bit high</th>
        <th>16 bit low</th>
    </tr>
    <tr>
        <th>32 bit</th>
        <th colspan="2">16 bit</th>
    </tr>
  <tr>
    <td>0000 0000 0000 0000</td>
    <td>0000 0000</td>
    <td>0000 0000</td>
  </tr>
  <tr>
      <td>E{reg name}X</td>
      <td>{reg name}H</td>
      <td>{reg name}L</td>
    </tr>
    <tr>
      <td></td>
      <td colspan="2">{regname}X</td>
    </tr>
    <tr>
      <td>`EAX EBX ECX EDX`</td>
      <td>`AH BH CH DH`</td>
      <td>`AL BL CL DL`</td>
    </tr>
    <tr>
      <td></td>
      <td colspan="2">`AX BX CX DX`</td>
    </tr>
</table>

## Data registers 

#### Accumulator Registers
_Used for I/O port access, arithmetic and interrupt calls_

|**Register**|**Name**                        | **Description**                                       |
|-----------:|-------------------------------:|------------------------------------------------------:|
|   AH       | Accumulator High Byte Register | The high byte of the 16 bit accumulator register      |
|   AL       | Accumulator Low Byte Register  | The low byte of the 16 bit accumulator register       |
|   AX       | Accumulator Register           | The combined high and low byte of the 16 bit register |
|   EAX      | Extended Accumulator Register  | The extended 32 bit accumulator register              |

#### Base Registers
_Used for indexing addressing_

|**Register**|**Name**                | **Description**                                           |
|-----------:|-----------------------:|----------------------------------------------------------:|
|   BH       |Base High Byte Register | The high byte of the 16 bit base register                 |
|   BL       |Base Low Byte Register  | The low byte of the 16 bit base register                  |
|   BX       |Base Register           | The combined high and low byte of the 16 bit base register|
|   EBX      |Extenden Base Register  | The extended 32 bit base register                         |  

#### ount Registers   
_Used to store the loop count in iterative operations_

|**Register**|**Name**                | **Description**                                             |
|-----------:|-----------------------:|------------------------------------------------------------:|
|   CH       |Count High Byte Register| The high byte of the 16 bit count register                  |
|   CL       |Count Low Byte Register | The low byte of the 16 bit count register                   |
|   CX       |Count Register          | The combined high and low byte of the 16 bit count register |
|   ECX      |Extenden Count Register | The extended 32 bit count register                          |

#### Data Registers
_Used in I/O operations and in combination with the accumilator registers for multiply and divide operations_

|**Register**|**Name**                | **Description**                                            |
|-----------:|-----------------------:|-----------------------------------------------------------:|
|   DH       | Data High Byte Register| The high byte of the 16 bit data register                  |
|   BL       | Data Low Byte Register | The low byte of the 16 bit data register                   |
|   BX       | Data Register          | The combined high and low byte of the 16 bit data register |
|   EBX      | Extenden Data Register | The extended 32 bit data register                          |

## Pointer Registers

#### Instruction Pointer Registers
_Used to store the offset address of the next instruction to be executed_

|**Register**|**Bits**|**Name**                               | 
|-----------:|-------:|--------------------------------------:|
|   IP       | 16     | Instruction Pointer Register          |
|   EIP      | 32     | Extended Instruction Pointer Register |

#### Stack Pointer Registers
_Used to store the offset address of the stack_

|**Register**|**Bits**|**Name**                        |
|-----------:|-------:|-------------------------------:|
|   SP       | 16     | Stack Pointer Register         | 
|   ESP      | 32     | Extended Stack Pointer Register| 

#### Base Pointer Registers
_Used in making references to parameters that are passed in subroutines_

|**Register**|**Bits**|**Name**                        |
|-----------:|-------:|-------------------------------:|
|   BP       | 16     | Base Pointer Register          |
|   EBP       | 32    | Extended Base Pointer Register |

## Control Registers
_These registers are used to configure modes on the cpu (Setting Flags) to alter its behaviour_

|**Register**|**Name**                | **Description**                                            |
|-----------:|-----------------------:|-----------------------------------------------------------:|
|   IF       | Interrupt Flag Register| This can be used to configure how external interrupts should be handled |
|   TF       | Trap Flag Register | This enables single-step mode for debugging (stepping through) instructions|
|   DF       | Direction Flag Register | This controls the direction for moving or comparing string data |
|   OF       | Overflow Flag Register |This indicates if an overflow occurred after an arithmetic operation|
|   SF       | Sign Flag Register |It shows the sign of the result of an arithmetic operation|
|   AF       | Auxiliary Cary Flag Register | |
|   PF       | Parity Flag Register | Indication of total number of 1 bits in the result of an arithmetic operation. |
|   CF       | Carry Flag Register | Contains the carry 1 or 0 bits after an arithmetic operation |
|   ZF       | Zerro Flag Register | It indicates 0 results after an comparison or arithmetic operation |

## Index Registers

### Source Index Registers
_Used as an source index for string operations_

|**Register**|**Bits**|**Name**                        |
|-----------:|-------:|-------------------------------:|
|   SI       | 16     | Source Index Register          | 
|   ESI      | 32     | Extended Source Index Register | 

####Destination Index Registers
_Used as destination index for string operations_

|**Register**|**Bits**|**Name**                            |
|-----------:|-------:|-----------------------------------:|
|   DI       | 16     | Destination Index Register         |
|   EDI      | 32     | Extended Destination Index Register |


## Segment Registers

#### Code Segment Registers
_This contains all the instructions to be executed_

|**Register**|**Bits**|**Name**                               | 
|-----------:|-------:|--------------------------------------:|
|   CS      | 16     | Code Segment Register                  |
|   ECS     | 32     | Extended Code Segment Register         |

#### Data Segment Registers
_This contains data, constants and work ares_

|**Register**|**Bits**|**Name**                        |
|-----------:|-------:|-------------------------------:|
|   DS       | 16     | Data segment Register          | 
|   EDS      | 32     | Extended Data segment Register | 
 
#### Stack Segment Registers
_This contains data and return addresses of subroutines, procederes. It is implemented as an stack
data structure_

|**Register**|**Bits**|**Name**                        |
|-----------:|-------:|-------------------------------:|
|   SS      | 16     | Stack Segment Register          |
|   ESS      | 32    | Extended Stack Segment Register |




