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
    ; libdessin.asm : librairie contenant les procedures de dessin
    ; 


PILE SEGMENT STACK  
    
DW 256 DUP(?)
Base:      
PILE ENDS

DATA SEGMENT   

DATA ENDS

CODE SEGMENT

ASSUME CS:CODE, DS:DATA, SS :PILE


PUBLIC  InitGraphe      ; passage en mode video
PUBLIC  DR              ; dessine un trait vers la droite
PUBLIC  BA              ; dessine un trait vers le bas
PUBLIC  HA              ; dessine un trait vers le haut
PUBLIC  GA              ; dessine un trait vers la gauche
PUBLIC  DIAG_MD         ; dessine une diagonale montante vers la droite
PUBLIC  DIAG_DD         ; dessine une diagonale descendante vers la droite 
PUBLIC  DIAG_DG         ; dessine une diagonale descendante vers la gauche
PUBLIC  DIAG_MG         ; dessine une diagonale montante vers la gauche





main:
    

;-------------------------------
;---- Procedure: InitGraphe ----
;---- Entree: aucune
;---- Sortie: la fenetre passe en mode video
;-------------------------------
 
InitGraphe PROC far
    
        PUSH AX
             
           MOV AX, 0013H	; mode video 320*200 256 couleurs
           INT 10H
           
        POP AX    

RET   
InitGraphe ENDP     
 

;-------------------------------
;---- Procedure: DR ----
;---- Entree: AX contient la position Colonne
;----         BX contient la position Ligne
;----         DX contient la Couleur
;----         CX contient la Longueur
;----         SI permet de choisir le mode BC | LC
;---- Sortie: un ou plusieurs pixel ont ete dessine
;------------------------------- 

DR PROC far
    
        PUSH BP                 ; bp+12 
        PUSH AX                 ; bp+8      Colonne
        PUSH BX                 ; bp+6      Ligne
        PUSH CX                 ; bp+4      Longueur
        PUSH DX                 ; bp+2      Couleur
        PUSH SI                 ; bp+0      BC | LC
            
        MOV BP, SP
        
        cmp si,0                     ; permet de definir
            je Init_Droite_debut     ; si on doit dessiner
            jne pas_de_dessin_debut  ; ou juste se deplacer
        
        pas_de_dessin_debut:     ;
        MOV SI, [BP+4]           ; si = longueur
        pas_de_dessin:           ;
                                 ;
            cmp si,0             ; si la longueur est atteinte
            je fin_DR            ; fin de la procedure
            mov ax,1             ;
            add [bp+6],ax        ; sinon on se deplace de 1 pixel  
            dec si               ; 
            jmp pas_de_dessin    ;
            
        
        Init_Droite_debut:      ;
        MOV SI, [BP+4]          ; si = longueur
        Init_Droite:            ;
                                ;
            CMP SI,0            ; si on la longueur est atteinte
            je fin_DR           ; fin de la procedure
            mov ax,1            ;
            ADD [BP+6],ax       ; sinon on se deplace de 1 pixel
            MOV AH, 0CH         ; permet de dessiner un point
            MOV AL, [BP+2]      ; al = Couleur
            MOV BH, 00H         ; 
            MOV CX, [BP+6]      ; cx = Ligne
            MOV DX, [BP+8]      ; dx = Colonne
            INT 10H             ;     
                                ;
            DEC SI              ; 
                                ;
            Jmp Init_Droite     ; 
        
        fin_DR:       ; procedure propre
                      ;
        POP SI        ;
        POP DX        ;
        POP CX        ;
        POP BX        ;
        POP AX        ;
        POP BP        ;
   
RET

DR ENDP


;-------------------------------
;---- Procedure: GA ----
;---- Entree: AX contient la position Colonne
;----         BX contient la position Ligne
;----         DX contient la Couleur
;----         CX contient la Longueur
;----         SI permet de choisir le mode BC | LC
;---- Sortie: un ou plusieurs pixel ont ete dessine
;------------------------------- 

GA  PROC far
    
        PUSH BP                 ; bp+10
        PUSH AX                 ; bp+8      Colonne
        PUSH BX                 ; bp+6      Ligne
        PUSH CX                 ; bp+4      Longueur
        PUSH DX                 ; bp+2      Couleur
        PUSH SI                 ; bp+0      BC | LC
            
        MOV BP, SP 
        
        mov si,[bp]                    ;
        cmp si,0                       ;
            je Init_Gauche_debut       ;
            jne pas_de_dessin_1_debut  ;
        
        pas_de_dessin_1_debut:         ;
        MOV SI, [BP+4]                 ;
        pas_de_dessin_1:               ;
                                       ;
            cmp si,0                   ;
            je fin_GA                  ;
            mov ax,1                   ;
            sub [bp+6],ax              ;       
            dec si                     ;
            jmp pas_de_dessin_1        ;
            
        
        Init_Gauche_debut:             ;
        MOV SI, [BP+4]                 ;
        Init_Gauche:                   ;
                                       ;
            CMP SI,0                   ;
            je fin_GA                  ;
            mov ax,1                   ;
            SUB [BP+6],ax              ;
            MOV AH, 0CH                ;
            MOV AL, [BP+2]             ;
            MOV BH, 00H                ;
            MOV CX, [BP+6]             ;
            MOV DX, [BP+8]             ;
            INT 10H                    ;
                                       ;
            DEC SI                     ;
                                       ;
            Jmp Init_Gauche            ;
        
        
        fin_GA:   ;
                  ;
        POP SI    ;
        POP DX    ;
        POP CX    ;
        POP BX    ;
        POP AX    ;
        POP BP    ;
  
RET

GA ENDP


;-------------------------------
;---- Procedure: BA ----
;---- Entree: AX contient la position Colonne
;----         BX contient la position Ligne
;----         DX contient la Couleur
;----         CX contient la Longueur
;----         SI permet de choisir le mode BC | LC
;---- Sortie: un ou plusieurs pixel ont ete dessine
;------------------------------- 

BA PROC far
    
        PUSH BP                 ; bp+10
        PUSH AX                 ; bp+8      Colonne
        PUSH BX                 ; bp+6      Ligne
        PUSH CX                 ; bp+4      Longueur
        PUSH DX                 ; bp+2      Couleur
        PUSH SI                 ; bp+0      BC | LC
            
        MOV BP, SP                       ;
        cmp si,0                         ;
            je Init_Bas_debut            ;
            jne pas_de_dessin_2_debut    ;
        
        pas_de_dessin_2_debut:           ;
        MOV SI, [BP+4]                   ;
        pas_de_dessin_2:                 ;
                                         ;
            cmp si,0                     ;
            je fin_BA                    ;
             mov ax,1                    ;
            add [bp+8],ax                ;
            dec si                       ;
            jmp pas_de_dessin_2          ;
            
        
        Init_Bas_debut:                  ;
        MOV SI, [BP+4]                   ;
        Init_Bas:                        ;
                                         ;
            CMP SI,0                     ;
            je fin_BA                    ;
            mov ax,1                     ;
            ADD [BP+8],ax                ;
            MOV AH, 0CH                  ;
            MOV AL, [BP+2]               ;
            MOV BH, 00H                  ;
            MOV CX, [BP+6]               ;
            MOV DX, [BP+8]               ;
            INT 10H                      ;
                                         ;
            DEC SI                       ;
            Jmp Init_Bas                 ;
        
        
        fin_BA:    ;
                   ;
        POP SI     ;
        POP DX     ;
        POP CX     ;
        POP BX     ;
        POP AX     ;
        POP BP     ;
           
RET

BA ENDP


;-------------------------------
;---- Procedure: HA ----
;---- Entree: AX contient la position Colonne
;----         BX contient la position Ligne
;----         DX contient la Couleur
;----         CX contient la Longueur
;----         SI permet de choisir le mode BC | LC
;---- Sortie: un ou plusieurs pixel ont ete dessine
;------------------------------- 
     
HA PROC far
    
        PUSH BP                 ; bp+10
        PUSH AX                 ; bp+8      Colonne
        PUSH BX                 ; bp+6      Ligne
        PUSH CX                 ; bp+4      Longueur
        PUSH DX                 ; bp+2      Couleur
        PUSH SI                 ; bp+0      BC | LC
            
        MOV BP, SP                     ;
        cmp si,0                       ;
            je Init_Haut_debut         ;
            jne pas_de_dessin_3_debut  ;
        
        pas_de_dessin_3_debut:         ;
        MOV SI, [BP+4]                 ;
        pas_de_dessin_3:               ;
                                       ;
            cmp si,0                   ;
            je fin_HA                  ;
            mov ax,1                   ;
            sub [bp+8],ax              ;
            dec si                     ;
            jmp pas_de_dessin_3        ;
            
        
        Init_Haut_debut:               ;
        MOV SI, [BP+4]                 ;
        Init_Haut:                     ;
                                       ;
            CMP SI,0                   ;
            je fin_HA                  ;
            mov ax,1                   ;
            SUB [BP+8],ax              ;
            MOV AH, 0CH                ;
            MOV AL, [BP+2]             ;
            MOV BH, 00H                ;
            MOV CX, [BP+6]             ;
            MOV DX, [BP+8]             ;
            INT 10H                    ;
                                       ;
            DEC SI                     ;
            Jmp Init_Haut              ;
        
        
        fin_HA:     ;
                    ;
        POP SI      ;
        POP DX      ;
        POP CX      ;
        POP BX      ;
        POP AX      ;
        POP BP      ;
   
RET

HA ENDP 



;-------------------------------
;---- Procedure: DIAG_MD ----
;---- Entree: AX contient la position Colonne
;----         BX contient la position Ligne
;----         DX contient la Couleur
;----         CX contient la Longueur
;----         SI permet de choisir le mode BC | LC
;---- Sortie: un ou plusieurs pixel ont ete dessine
;------------------------------- 

DIAG_MD PROC far
    
        PUSH BP                 ; bp+12 
        PUSH AX                 ; bp+8      Colonne
        PUSH BX                 ; bp+6      Ligne
        PUSH CX                 ; bp+4      Longueur
        PUSH DX                 ; bp+2      Couleur
        PUSH SI                 ; bp+0      BC | LC
            
        MOV BP, SP                      ;
        cmp si,0                        ;
            je Init_Diag_md_debut       ;
            jne pas_de_dessin_debut_4   ;
        
        pas_de_dessin_debut_4:          ;
        MOV SI, [BP+4]                  ;
        pas_de_dessin_4:                ;
                                        ;
            cmp si,0                    ;
            je fin_diag_md              ;
                                        ;
            mov ax,1                    ;
            add [bp+6],ax               ;
            sub [bp+8],ax               ;
                                        ;
            dec si                      ;
            jmp pas_de_dessin_4         ;

        
        Init_Diag_md_debut:             ;
        MOV SI, [BP+4]                  ;
        Init_Diag_md:                   ;
                                        ;
            CMP SI,0                    ;
            je fin_diag_md              ;
            mov ax,1                    ;
            ADD [BP+6],ax               ;
            SUB [BP+8],ax               ;
            MOV AH, 0CH                 ;
            MOV AL, [BP+2]              ;
            MOV BH, 00H                 ;
            MOV CX, [BP+6]              ;
            MOV DX, [BP+8]              ;
            INT 10H                     ;
                                        ;
            DEC SI                      ;      
            Jmp Init_Diag_md            ;
        
        fin_diag_md:    ;
                        ;
        POP SI          ;
        POP DX          ;
        POP CX          ;
        POP BX          ;
        POP AX          ;
        POP BP          ;
   
RET

DIAG_MD ENDP

;-------------------------------
;---- Procedure: DIAG_MG ----
;---- Entree: AX contient la position Colonne
;----         BX contient la position Ligne
;----         DX contient la Couleur
;----         CX contient la Longueur
;----         SI permet de choisir le mode BC | LC
;---- Sortie: un ou plusieurs pixel ont ete dessine
;------------------------------- 

DIAG_MG PROC far
    
        PUSH BP                 ; bp+12 
        PUSH AX                 ; bp+8      Colonne
        PUSH BX                 ; bp+6      Ligne
        PUSH CX                 ; bp+4      Longueur
        PUSH DX                 ; bp+2      Couleur
        PUSH SI                 ; bp+0      BC | LC
            
        MOV BP, SP                      ;       
        cmp si,0                        ;
            je Init_Diag_mg_debut       ;
            jne pas_de_dessin_debut_5   ;
        
        pas_de_dessin_debut_5:          ;
        MOV SI, [BP+4]                  ;
        pas_de_dessin_5:                ;
                                        ;
            cmp si,0                    ;
            je fin_diag_mg              ;
                                        ;
            mov ax,1                    ;
            sub [bp+6],ax               ;
            sub [bp+8],ax               ;
                                        ;
            dec si                      ;
            jmp pas_de_dessin_5         ;
            
        
        Init_Diag_mg_debut:             ;
        MOV SI, [BP+4]                  ;
        Init_Diag_mg:                   ;
                                        ;
            CMP SI,0                    ;
            je fin_diag_mg              ;
                                        ;
            mov ax,1                    ;
            sub [BP+6],ax               ;
            SUB [BP+8],ax               ;
            MOV AH, 0CH                 ;
            MOV AL, [BP+2]              ;
            MOV BH, 00H                 ;
            MOV CX, [BP+6]              ;
            MOV DX, [BP+8]              ;
            INT 10H                     ;
                                        ;
            DEC SI                      ;   
            Jmp Init_Diag_mg            ;
        
        fin_diag_mg:    ;
                        ;
        POP SI          ;
        POP DX          ;
        POP CX          ;
        POP BX          ;
        POP AX          ;
        POP BP          ;
   
RET

DIAG_MG ENDP 


;-------------------------------
;---- Procedure: DIAG_DD ----
;---- Entree: AX contient la position Colonne
;----         BX contient la position Ligne
;----         DX contient la Couleur
;----         CX contient la Longueur
;----         SI permet de choisir le mode BC | LC
;---- Sortie: un ou plusieurs pixel ont ete dessine
;------------------------------- 

DIAG_DD PROC far
    
        PUSH BP                 ; bp+12 
        PUSH AX                 ; bp+8      Colonne
        PUSH BX                 ; bp+6      Ligne
        PUSH CX                 ; bp+4      Longueur
        PUSH DX                 ; bp+2      Couleur
        PUSH SI                 ; bp+0      BC | LC
            
        MOV BP, SP                      ;
        cmp si,0                        ;
            je Init_Diag_dd_debut       ;
            jne pas_de_dessin_debut_6   ;
        
        pas_de_dessin_debut_6:          ;
        MOV SI, [BP+4]                  ;
        pas_de_dessin_6:                ;
                                        ;
            cmp si,0                    ;
            je fin_diag_dd              ;
                                        ;
            mov ax,1                    ;
            add [bp+6],ax               ;
            add [bp+8],ax               ;
                                        ;
            dec si                      ;
            jmp pas_de_dessin_6         ;
            
        
        Init_Diag_dd_debut:             ;
        MOV SI, [BP+4]                  ;
        Init_Diag_dd:                   ;
                                        ;
            CMP SI,0                    ;
            je fin_diag_dd              ;
                                        ;
            mov ax,1                    ;
            add [BP+6],ax               ;
            add [BP+8],ax               ;
            MOV AH, 0CH                 ;
            MOV AL, [BP+2]              ;
            MOV BH, 00H                 ;
            MOV CX, [BP+6]              ;
            MOV DX, [BP+8]              ;
            INT 10H                     ;
                                        ;
            DEC SI                      ;     
            Jmp Init_Diag_dd            ;
        
        fin_diag_dd:    ;
                        ;
        POP SI          ;
        POP DX          ;
        POP CX          ;
        POP BX          ;
        POP AX          ;
        POP BP          ;
   
RET

DIAG_DD ENDP


;-------------------------------
;---- Procedure: DIAG_DG ----
;---- Entree: AX contient la position Colonne
;----         BX contient la position Ligne
;----         DX contient la Couleur
;----         CX contient la Longueur
;----         SI permet de choisir le mode BC | LC
;---- Sortie: un ou plusieurs pixel ont ete dessine
;------------------------------- 

DIAG_DG PROC far
    
        PUSH BP                 ; bp+12 
        PUSH AX                 ; bp+8      Colonne
        PUSH BX                 ; bp+6      Ligne
        PUSH CX                 ; bp+4      Longueur
        PUSH DX                 ; bp+2      Couleur
        PUSH SI                 ; bp+0      BC | LC
            
        MOV BP, SP                      ;
        cmp si,0                        ;
            je Init_Diag_dg_debut       ;
            jne pas_de_dessin_debut_7   ;
        
        pas_de_dessin_debut_7:          ;
        MOV SI, [BP+4]                  ;
        pas_de_dessin_7:                ;
                                        ;
            cmp si,0                    ;
            je fin_diag_dg              ;
                                        ;
            mov ax,1                    ;
            sub [bp+6],ax               ;
            add [bp+8],ax               ;
                                        ;
            dec si                      ;
            jmp pas_de_dessin_7         ;
            
        
        Init_Diag_dg_debut:             ;
        MOV SI, [BP+4]                  ;
        Init_Diag_dg:                   ;
                                        ;
            CMP SI,0                    ;
            je fin_diag_dg              ;
                                        ;
            mov ax,1                    ;
            sub [BP+6],ax               ;
            add [BP+8],ax               ;
            MOV AH, 0CH                 ;
            MOV AL, [BP+2]              ;
            MOV BH, 00H                 ; 
            MOV CX, [BP+6]              ;
            MOV DX, [BP+8]              ;
            INT 10H                     ;
                                        ;
            DEC SI                      ;  
            Jmp Init_Diag_dg            ;
        
        fin_diag_dg:    ;
                        ;
        POP SI          ;
        POP DX          ;
        POP CX          ;
        POP BX          ;
        POP AX          ;
        POP BP          ;
   
RET
              
              
DIAG_DG ENDP  

 


CODE ENDS
END main 
