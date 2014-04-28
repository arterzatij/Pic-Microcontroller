;=========================================================================
; Acerca
;
; Ejecuta el algoritmo de ordenamiento de la burbuja (http://es.wikipedia.org/wiki/Bubble_sort)
; el ordenamiento se lleva a cabo utilizando el apuntador del microcontrolador (FSR and INDF)
; es un procesamiento en memoria el que se lleva a cabo, asi que no tiene interaccion con los perifericos.
; La manera de inicializar los numeros es utilizando una macro (vector.add) y con la ayuda 
; del preprocesador de MPLAB se inicializa la memoria con los datos a ordenar.
; Esta practica sirve para ver el funcionamiento del apuntador, asi como algunas caracteristicas 
; del preprocesador.
; Tambien se definen macros en el programa las cuales ayudaran de mucho en la reutilizacion de codigo.


;=========================================================================
; Configuracion de procesador

  #include <p16f84.inc>
  list p=16f84

;=========================================================================
; Configuracion de fusibles

  __CONFIG _XT_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF

;=========================================================================
; Macros

popf  macro ptr, x
    movf  ptr, w
    movwf FSR
    movf  INDF, w
    movwf x
    endm

pushf macro ptr, x
    movf  ptr, w
    movwf FSR
    movf  x, w
    movwf INDF
    endm

swapff  macro x, y
    movf  x, w
    movwf temp
    movf  y, w
    movwf x
    movf  temp, w
    movwf y
    endm

greater macro x, y
  local @true
  local @false
  local @end
  movf  x, w
  subwf y, w
  btfss STATUS, C
    goto  @true
    goto  @false
@true:
  movlw 0x01
  goto  @end
@false:
  clrw
@end:
  endm

vector.add  macro  int
  movlw vector + vector.length
  movwf FSR
  movlw int
  movwf INDF
vector.length += 1
  endm
  
  
;=========================================================================
; Variables

vector    equ 0x0C
  variable  vector.length = 0
  
;=========================================================================
; Constantes

cblock 0x40
  ptri
  ptrj
  temp
  m_a
  m_b
  i
  j
endc

;=========================================================================
; Main

  org 0x00

start:

  ;int[] vector = { 44, 55, 12, 42, 94, 18, 6, 67, 43, 102 }
  vector.add d'44'
  vector.add d'55'
  vector.add d'12'
  vector.add d'42'
  vector.add d'94'
  vector.add d'18'
  vector.add d'6'
  vector.add d'67'
  vector.add d'43'
  vector.add d'102'
  ; para ingresar mas numeros solo ocupan: vector.add numero
  ; el programa calcula dinamicamente la longitud del vector

  movlw vector.length - 1
  movwf i

  movlw vector
  movwf ptri        ; ptri <- &vector (ptri almacenara la direccion de memoria de vector)

@vector:
  movf  i, w
  movwf j

  movf  ptri, w
  movwf ptrj
  incf  ptrj, f

@test:
  popf  ptri, m_a
  popf  ptrj, m_b
  greater m_a, m_b  ; w <- ( m_a > m_b )
  xorlw 0x01        ; w <- !w
  btfss STATUS, Z
  ;if ( !z ) {
    goto  @menor
  ;}
  ;else {
    swapff m_a, m_b
    pushf ptri, m_a
    pushf ptrj, m_b
  ;}
@menor:
  incf  ptrj, f
  decfsz  j, f
    goto  @test
  incf ptri,  f
  decfsz  i, f
    goto  @vector
  goto $

  end
