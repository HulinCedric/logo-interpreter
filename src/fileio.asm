    ;
    ; IUT de Nice / Departement informatique / ASR2
    ; Annee 2008_2009 
    ;
    ; PROJET ASR2 - LOGO - Etape 4
    ;                              
    ; Auteurs : FOUCO Charles - HULIN Cedric
    ;
    ; Copyright © 2009 - FOUCO Charles - HULIN Cedric
    ;
    ;
    ; fileio.asm : librairie de gestion des fichiers (ouverture, lecture, fermeture).
    ;


PILE SEGMENT STACK  
    
DW 256 DUP(?)
Base:      
PILE ENDS

DATA SEGMENT   

DATA ENDS

CODE SEGMENT

ASSUME CS:CODE, DS:DATA, SS :PILE

PUBLIC openFile     ; ouverture du fichier
PUBLIC readFile     ; lecture du fichier
PUBLIC closeFile    ; fermeture du fichier

main:    



;-------------------------------
;---- Procedure: openFile ----
;---- Entree: DX contient l'adresse de la variable contenant le nom du fichier
;----         le nom fini par le caractère 0
;----         AX contient l'handle
;---- Sortie: le fichier indique par DX est ouvert
;-------------------------------

openFile PROC FAR

        PUSH BP                 ; bp+10
        PUSH SI                 ; bp+8
        PUSH AX                 ; bp+6       Handle                     
        PUSH BX                 ; bp+4
        PUSH CX                 ; bp+2
        PUSH DX                 ; bp         Fichier a ouvrir             
         
        MOV BP, SP
         
        Ouverture_de_fichier:    
            
            MOV DX, [BP]        ; on met dans dx le fichier a ouvrir
            MOV AX, 3D00H       ;
            INT 21H             ;
             
            MOV SI, [BP+6]      ;
            MOV DS:[SI], AX     ; On sauvegarde l'handle du fichier
        
        
        POP DX
        POP CX
        POP BX
        POP AX
        POP SI
        POP BP

RET
openFile ENDP




;-------------------------------
;---- Procedure: readFile ----
;---- Entree: DX contient l'adresse de la variable contenant le nom du fichier
;----         le nom fini par le caractere 0
;----         DX contient l'adresse de la variable ou sauver le contenu du fichier
;----         CX contient le nombre d'octets a lire
;----         les variables se trouvent dans le segment de donnee local
;---- Sortie: la variable indiquee par DX est mise a jour
;-------------------------------

readFile PROC FAR

        PUSH BP                 ; bp+10
        PUSH SI                 ; bp+8
        PUSH AX                 ; bp+6       Handle                     
        PUSH BX                 ; bp+4                          
        PUSH CX                 ; bp+2       Nombre de caractere lue    
        PUSH DX                 ; bp         Buffer qui va contenir le contenu du fichier lu
        
        MOV BP, SP 
              
            Lecture_Fichier:    
        
            MOV SI, [BP+6]
            MOV BX, DS:[SI]     ; Handle AX->BX
            MOV AX, 3F00H
            MOV CX, [BP+2]      ; CX contient le nombre d'octets a lire
            MOV DX, [BP]        ; DX contient le Buffer 
            INT 21H     
        
        POP DX
        POP CX
        POP BX
        POP AX
        POP SI
        POP BP

RET
readFile ENDP 



;-------------------------------
;---- Procedure: closeFile ----
;---- Entree: AX contient l'adresse de la variable contenant le nom du fichier
;----         le nom fini par le caractère 0
;----         la variable se trouve dans le segment de donnee local
;---- Sortie: le fichier indique par AX est ferme
;-------------------------------

closeFile PROC FAR

        PUSH BP                 ; bp+10
        PUSH SI                 ; bp+8
        PUSH AX                 ; bp+6       Handle                     
        PUSH BX                 ; bp+4                          
        PUSH CX                 ; bp+2           
        PUSH DX                 ; bp               
         
        MOV BP, SP 
         
        Fermeture_De_Fichier:
            
            MOV SI, [BP+6]
            MOV BX, DS:[SI]  
            MOV AX, 3E00H  
            INT 21H
            
        POP DX
        POP CX
        POP BX
        POP AX
        POP SI
        POP BP

RET
closeFile ENDP  
          
CODE ENDS
END main 