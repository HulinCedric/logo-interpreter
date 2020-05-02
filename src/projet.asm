    ;
    ; IUT de Nice / Departement informatique / ASR2
    ; Annee 2008_2009 
    ;
    ; PROJET ASR2 - LOGO - PHASE 4
    ;                              
    ; Auteurs : FOUCO Charles - HULIN Cedric
    ;
    ; Copyright © 2009 - FOUCO Charles - HULIN Cedric
    ;
    ;
    ; Rotations avancees        : OK
    ; Mode interactif           : OK
    ; Interface globale         : OK
    ; Mode interactif avance    : OK
    ; Mode pilotage             : OK 
    
    

PILE SEGMENT STACK  
    
    DW 256 DUP(?)
Base:      
PILE ENDS

DATA SEGMENT   

       
        buffer                      db  20 DUP(?)       ; buffer a ajuster selon le nombre d'octets
        handle                      dw  ?
        filename                    db  30, ?, 30 DUP(?)
        
        Tipe                        dw  ?            ; H | B | G | D
        Ligne                       dw  ?            ; Valeur sous la forme de 3 digits
        Colonne                     dw  ?            ; Valeur sous la forme de 3 digits
        Longueur                    dw  ?            ; Valeur sous la forme de 3 digits
        Couleur                     dw  ?            ; Valeur sous la forme d'un chiffre Hexadecimal   
        
        degres                      dw  0            ; permet de definir l'angle de rotation
        crayon                      dw  0            ; permet de savoir si on leve le crayon ou pas
        reculer_info                dw  0            ; permet de savoir si on recule (mouvement)

        passage_deplacement_logo    dw  0            ; permet de savoir si on s'est deplacer
        passage_main_etape1         dw  0            ; permet de savoir si on a demande l'etape 1
        
        message_mode                db  10,13,10,13,'Bonjour, voici les etapes que vous pouvez choisir $'
        message_etape               db  10,13,'Etape 1: tappez 1',10,13,'Etape 2: tappez 2',10,13,'Etape 3: tappez 3',10,13,'Mode pilotage : tappez 4$'  
        message_choix               db  10,13,10,13,'Veuillez entrer votre choix :$'
        message_erreur_choix        db  ' Erreur ! choix invalide$'
        message_projet              db  10,13,'         PROJET ASR2 LOGO annee 2008/2009$'
        message_entrer_fichier      db  10,13,10,13,'Entrer le nom du fichier a ouvrir : $'
        message_cree_fichier        db  10,13,10,13,'Entrer le nom du fichier a cree : $'
                                                                                                     
        choix                       db  10,13,10,13,'Mode Interactif: tappez 1',10,13,'Mode Fichier: tappez 2$'
        mod_interacif               db  0
        buffer_interactif           db  20, ?, 20 DUP(?)      
        buffer_retligne             db  13,10
        prompt                      db  ' Instruction : $'
        propre                      db  '                      $'
                                                                                               
DATA ENDS

CODE SEGMENT

ASSUME CS:CODE, DS:DATA, SS :PILE

EXTRN  openFile:    FAR     ; ouverture du fichier
EXTRN  readFile:    FAR     ; lecture du fichier
EXTRN  closeFile:   FAR     ; fermeture du fichier

EXTRN  InitGraphe:  FAR     ; passage en mode video

EXTRN  DR:          FAR     ; dessine un trait vers la droite
EXTRN  BA:          FAR     ; dessine un trait vers le bas
EXTRN  HA:          FAR     ; dessine un trait vers le haut
EXTRN  GA:          FAR     ; dessine un trait vers la gauche
EXTRN  DIAG_MD:       FAR   ; diagonale montante vers la droite
EXTRN  DIAG_DD:       FAR   ; diagonale descendante vers la droite
EXTRN  DIAG_DG:       FAR   ; diagonale descendante vers la gauche
EXTRN  DIAG_MG:       FAR   ; diagonale montante vers la gauche

main:    

        MOV AX,DATA 
        MOV DS,AX
    
        MOV AX,PILE
        MOV SS,AX   
        MOV SP,Base
        
        mov dx,offset message_projet    ; PROJET ASR2 LOGO annee 2008/2009 
        mov ah,09h                      ;
        int 21h                         ;
        
        mov dx,offset message_mode      ; Bonjour, voici les etapes que vous pouvez choisir
        mov ah,09h                      ;
        int 21h                         ;
        
        mov dx,offset message_etape     ; Etape 1 : tappez 1
        mov ah,09h                      ; Etape 2 : tappez 2
        int 21h                         ; Etape 3 : tappez 3 
                                        ; Mode pilotage : tappez 4
                     
        
        mov dx,offset message_choix     ; Veuillez entrer votre choix :
        mov ah,09h                      ;
        int 21h                         ;
        
        mov ah,01h                      ; l'utilisateur entre son choix
        int 21h                         ;        
        sub al,30h                      ;
        
        cmp al,1                        ; saut au choix correspondant
            je main_etape_1             ;
        cmp al,2                        ;
            je main_etape_2             ;
        cmp al,3                        ;
            je main_etape_3             ;
        cmp al,4                        ;
            je mode_pilotage            ;
    
        jne erreur_choix                ; si le choix n'est pas valide
        
        
        main_etape_1:                   ; Etape 1
            mov passage_main_etape1,1   ; permet de lire qu'une ligne dans l'etape 2
            call main2                  ;
            jmp Fin_main_principal      ;
        
        main_etape_2:                   ; Etape 2
            call main2                  ;
            jmp Fin_main_principal      ;
            
        main_etape_3:                   ; Etape 3
            call main3                  ;
            jmp Fin_main_principal      ;
        
	    mode_pilotage:            	    ; Mode Pilotage
            call pilotage		        ;
            jmp Fin_main_principal	    ;

        erreur_choix:                           ; Choix non valide
            mov dx,offset message_erreur_choix  ; Affichage d'un message d'erreur
            mov ah,09h                          ;
            int 21h                             ;
            jmp Fin_main_principal              ;
        
      
Fin_main_principal:

    CMP mod_interacif, 1
    JE TheEnd                  ; si nous somme en mode interactif
                               ; il est inutile de freeze le fenetre
                               ; car cela demanderai a l'utilisateur
Freeze:                        ; de re appuyer sur une touche
                               ; ici nous pallions a ce probleme
     mov passage_main_etape1,0
     
     MOV AH,00H
     INT 16H

TheEnd:       
     
     CMP passage_main_etape1,1
     JE Freeze                
        
     MOV AH,4CH                 ; les deux lignes necessaire
     INT 21H                    ; a la fin du programme
         
        
        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;                                   ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;            MODE PILOTAGE          ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;                                   ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pilotage proc near
                        
      mov Colonne,10    ; Initialisation des
      mov Ligne,10      ; parametres par defaut
      mov Longueur,2    ;
      mov Couleur,3     ;
      mov crayon,0      ;
      
      
      mov bx,Ligne      ;
      mov cx,Longueur   ;
      mov dx,Couleur    ;
      mov si,crayon     ;
      
      CALL InitGraphe   ; Passage en mode graphique
          
      boucle_pilotage:
                                  
            mov ah,0h   ; L'utilisateur entre 
            int 16h     ; une touche
            
   
            cmp ax,4800h        ; touche 'fleche haut' 
            je fleche_haut      ;            
                        
            cmp ax,4B00h        ; touche 'fleche gauche'
            je fleche_gauche    ;
                        
            cmp ax,4D00h        ; touche 'fleche droite'
            je fleche_droite    ;
            
            cmp ax,5000h        ; touche 'fleche bas'
            je fleche_bas       ;
                        
            cmp al,4Ch          ; touche 'L' 
            je pilotage_LC      ;
            
            cmp al,6ch          ; touche 'l'
            je pilotage_LC      ;
            
            
            cmp al,41h            ; touche 'A' 
            je augmenter_longueur ;
            
            cmp al,61h            ; touche 'a'
            je augmenter_longueur ;
            
            cmp al,44h            ; touche 'D'
            je diminuer_longueur  ;
            
            cmp al,64h            ; touche 'd'
            je diminuer_longueur  ;
            
             
            cmp ax,011Bh          ; touche 'echap'
            je fin_pilotage       ;
                                   
                                   
            cmp al,'1'            ; pave numerique
            jge test_color_2      ; pour le choix
            jmp fin_pilotage      ; des couleurs
                                  ;
                test_color_2:     ;
                sub al,30h        ;
                cmp al,9          ;
                jle color         ;
                jmp fin_pilotage  ;
            
            fleche_haut:             ; 
                mov ax,Colonne       ;
                call FAR PTR HA      ;
                mov Colonne,ax       ; sauvegarde de               
                mov Ligne,bx         ; la position                   
                jmp boucle_pilotage  ;            
            
            fleche_gauche:           ;
                mov ax,Colonne       ;
                call FAR PTR GA      ;
                mov Colonne,ax       ;               
                mov Ligne,bx         ;                    
                jmp boucle_pilotage  ;
            
            fleche_droite:           ;
                mov ax,Colonne       ;
                call FAR PTR DR      ;
                mov Colonne,ax       ;               
                mov Ligne,bx         ;                    
                jmp boucle_pilotage  ;
            
            fleche_bas:              ;
                mov ax,Colonne       ;
                call FAR PTR BA      ;
                mov Colonne,ax       ;               
                mov Ligne,bx         ;                    
                jmp boucle_pilotage  ;
                
            color:                   ;
                mov crayon,0         ;  
                mov si,crayon        ; passage en mode BC
                mov Couleur,ax       ; 
                mov dx,Couleur       ; choix couleur
                jmp boucle_pilotage  ;
                
            pilotage_LC:             ;
                mov crayon,1         ; 
                mov si,crayon        ; passage en mode LC
                jmp boucle_pilotage  ;
                
            augmenter_longueur:      ;
                add longueur,1       ;
                mov cx,longueur      ;
                jmp boucle_pilotage  ;
                
            diminuer_longueur:       ;
                cmp longueur,1       ;
                jle boucle_pilotage  ;
                                     ;
                sub longueur,1       ;
                mov cx,longueur      ;
                jmp boucle_pilotage  ;
                
             
    
fin_pilotage:
ret
pilotage endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;                                   ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;           MAIN ETAPE 3            ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;                                   ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main3 proc near

      
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
       
        choix_interactif_fichier:   ; ici nous proposons a l'utilisateur de choisir entre le mode interactif et le mode de lecture dans un fichier

        MOV DX, OFFSET choix    ;
        MOV AH, 09H             ; l'affichage d'un menu
        INT 21H                 ;
        
        mov dx,offset message_choix     ; Veuillez entrer votre choix :
        mov ah,09h                      ;
        int 21h
    
        mov ah,01h                      ; l'utilisateur entre son choix
        int 21h                         ;        
        sub al,30h                      ;
        
        cmp al,1                        ; saut au choix correspondant
            je mode_interactif          ;
        cmp al,2                        ;
            je OuvertureDeFichier       ;
            
        jne erreur_choix                ; si le choix n'est pas valide    
       
        mode_interactif: 
      
        MOV mod_interacif, 1    ; nous utiliserons une varaible mod_interactif afin de sauvegarder son choix
                               
        cree_fichier:           ; le mode interactif, cree un fichier
            
            
            ; lecture du nom du chemin du repertoire
    	    ;   
    	    mov dx,offset message_cree_fichier
    	    mov ah,09h
    	    int 21h
    	
    	    MOV AX, 0A00H            ; 
            MOV DX, OFFSET filename  ; et nous recuperons son souhait dans un buffer de type chaine de caractere
            INT 21H                  ;
        
            MOV BL,filename[1]
            MOV filename[BX+2],0
            
            MOV AX, 3C00H               ; via l'interuption 3C->AH
	        MOV CX, 0000H               ; donnons l'attribut normal au fichier.
	        MOV DX, OFFSET filename+2   ; nom du fichier text.txt stoker dans chemin
	        INT 21H
	       
	        ;JC Erreur              ; controle des erreur                  
            
            MOV handle, AX              ; l'endroit du fichier est sauvegarder dans la variable handle         
             
            JMP ecriture_dans_buffer    ; nous pouvons maintenant proposer a l'utilisateur de participer               
        
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;    
       
        
        OuvertureDeFichier:
                       
        ; lecture du nom du chemin du repertoire
    	;
    	mov dx,offset message_entrer_fichier
    	mov ah,09h
    	int 21h
    	
    	MOV AX, 0A00H            ; 
        MOV DX, OFFSET filename  ; et nous recuperons son souhait dans un buffer de type chaine de caractere
        INT 21H                  ;
        
        MOV BL,filename[1]
        MOV filename[BX+2],0
    	               
        CALL FAR PTR InitGraphe  
            
        MOV AX, OFFSET handle           ; ouverture du fichier
        MOV DX, OFFSET filename+2       ;                                    
        CALL  FAR PTR openFile          ;
      
        CMP mod_interacif, 0
        JE LectureDeFichier
      
      
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
      ecriture_dans_buffer:         ; le mode interactif, fait participer l'utilisateur en ecrivant directement ce que doit faire le crayon
        
        CALL InitGraphe             ; nous passons en mode video
        
        MOV DX, OFFSET prompt       ; 
        MOV AX, 0900H               ; nous proposons a l'utilisateur d'ecrire
        INT 21H                     ;
        
        MOV AX, 0A00H                     ; 
        MOV DX, OFFSET buffer_interactif  ; et nous recuperons son souhait dans un buffer de type chaine de caractere
        INT 21H                           ;
        
        CMP buffer_interactif[2], 'Q'    ; si le choix est Q, nous quittons le programme
        JE Fin                           ;
        
      ecrirture_dans_fichier:
      
        MOV DX, OFFSET buffer_interactif+2 ; ce buffer est compose a la premiere place, du nombre max de caractere qu'il peu stocker, a la seconde place, du nombre actuel de caracter qu'il a en stocke, et ensuite la chaine de caractere, nous passons donc +2 pour donner la chaine de caractere 
        MOV AX, 4000H                      ; interuption permetant d'ecrire dans un fichier
        MOV BX, handle                     ; nous passons en parametre le handle, endroit ou est le fichier et aussi l'endroit ou est le curseur dans le fichier
        MOV CH, 00H                        ; reinite ch a 0
        MOV CL, buffer_interactif[1]       ; dans ce buffer, au deuxieme emplacement, se trouve le nombre de caracteres entrer par l'utilisateur 
        INT 21H
    
        ;JB Erreur 
   
      copie_buffer:                        ; CX ayant le nombre de caracter en stock, et SI a 0
      
        MOV AH,buffer_interactif[SI+2]     ; nous allons copier la chaine de caractere du buffer interactif
        MOV buffer[SI],AH                  ; dans le buffer fichier afin d'utiliser les meme procedure dans le programme 'alege le code'
        INC SI                             ; par le biais d'une boucle en incrementant SI, pour parcourir les buffer et decrementant cx pour sortir de la boucle
        
        LOOP copie_buffer
        
        
        JMP lire_instruction               ; nous pouvons maintenant traiter la demande de l'utilisateur

     ;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        
        LectureDeFichier:
        
        MOV AX, OFFSET handle   ; lecture du fichier
        MOV DX, OFFSET buffer   ;
        MOV CX, 000BH           ;
                                ;
        CALL  FAR PTR readFile  ;
        

        lire_instruction:
                
                MOV SI,0
                MOV AH,0
                
                mov bl,10               ; bx : coefficient multiplicateur = 10
                
                mov al,buffer[si+2]     ; on prend le chiffre des centaine : 1__
                mul bl                  ; on le multiplie par 10           : 10
                add al,buffer[si+3]     ; on ajoute le chiffre des dizaine : _1_
                mul bl                  ; on le multiplie par 10           : 110
                add al,buffer[si+4]     ; on ajoute le chiffre des unite   : __1
                add ax,30h              ; on ajoute 30h pour avoir un resultat utilisable
                                        ; resultat : 111
                mov ah,0                ;
                MOV Ligne, ax           ; on met le resultat dans la variable Ligne
               
                
                mov al,buffer[si+6]     ; on recupere dans le fichier le nombre
                mul bl                  ; correspondant a la colonne
                add al,buffer[si+7]     ;
                mul bl                  ;
                add al,buffer[si+8]     ;
                add ax,30h              ;
                                        ;                             
                mov ah,0                ; 
                MOV Colonne, ax         ; on met le resultat dans la variable Colonne  
                
                
                mov al, buffer[si+10]   ; on  recupere  la  couleur  dans le  fichier
                cmp al, 40h             ; si la couleur est  un  chiffre  en  decimal
                    jle inferieur_a_40  ; alors on saute a l'etiquette correspondante
                    jmp superieur_a_40  ; sinon la couleur est en hexadecimal
                                        ;
                    inferieur_a_40:     ;
                    sub al, 30H         ; on enleve 30h pour avoir la vraie valeur
                                        ;
                superieur_a_40:         ;
                mov ah,00h              ;
                MOV Couleur, AX         ;
             
     
            
    Recupere_donnee_dans_fichier:
       
         CMP mod_interacif, 0      ;comme nous entrons dans une partie de code commune au deux mode, interactif et fichier, nous regardonc l'etat de la variable mod_interactif 
        JE modfichier             ; si celle-ci est a 0, nous allons au mod fichier, sinon au mod interactif
     
     Position_curseur:
        
        MOV DX, 0000H            ; 
        MOV AX, 0200H            ;
        INT 10H                  ;
                                 ; cette partie de code permet
        MOV DX, OFFSET prompt    ; de ne pas surchager l'ecran
        MOV AX, 0900H            ; des nombreuse commande
        INT 21H                  ; que pourrai enter l'utilisateur
                                 ;
        MOV DX, OFFSET propre    ;
        MOV AX, 0900H            ;
        INT 21H                  ;
                                 ;
        MOV DX, 000FH            ;
        MOV AX, 0200H            ;
        INT 10H                  ;

     interactifproc:
     
      
        
        MOV AX, 0A00H                    ;
        MOV DX, OFFSET buffer_interactif ; recupere l'instruction de l'utilisateur
        INT 21H                          ;
        
        CMP buffer_interactif[2], 'Q'    ; si le choix est Q, nous quittons le programme
        JE Fin                           ;
      
  

        MOV DX, OFFSET buffer_retligne   ; nous retournons a la ligne
        MOV AX, 4000H                    ; dans le fichier
        MOV BX, handle                   ;
        MOV CX, 0002H                    ;  
        INT 21H                          ;
        
        
        MOV DX, OFFSET buffer_interactif+2 ;
        MOV AX, 4000H                      ; puis nous y ecrivons son instruction
        MOV BX, handle                     ;
        MOV CH, 00H                        ;
        MOV CL, buffer_interactif[1]       ;  
        INT 21H
    
        ;JB Erreur 
        
        MOV SI, 2                          ; nous imposons SI a 2, c'est-a-dire, commencer a ecrire dans le buffer a la 3e place, car notre mod fichier nous l'impose, nous pouvons donc utiliser le meme code en fichier ou en interactif
        
      copie_buffer2:
      
        MOV AH,buffer_interactif[SI]       ; 
        MOV buffer[SI],AH                  ; copier le buffer interactif dans le buffer
        INC SI                             ;
                                           ;
        LOOP copie_buffer2                 ;
                                           
        MOV SI, 3                          ; met SI a 3 afin de coller au mod fichier
        
        JMP Analyse_et_stockage_du_fichier ; nous allons maintenant traiter la demande de l'utilisateur comme si elle ete ecrite dans un fichier   
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                 
    
     modfichier:
               
     
        MOV AX, OFFSET handle   ; lecture du fichier
        MOV DX, OFFSET buffer   ;
        MOV CX, 0003H           ;
                                ;
        CALL  FAR PTR readFile  ;                                 
        
        MOV SI,0
                                      
        Analyse_et_stockage_du_fichier: 
            
            
                
            cmp buffer[2],'T'       ; Si la premiere lettre de la ligne      
                je rotation_logo    ; correspond a T,A,R,B ou L on saute
                                    ; a l'etiquette correspondante
            cmp buffer[2],'A'       ;
                je deplacement_logo ;
                                    ;
            cmp buffer[2],'R'       ;
                je deplacement_logo ;
                                    ;
            cmp buffer[2],'B'       ;
                je couleur_logo     ;
                                    ;
            cmp buffer[2],'L'       ;
                je couleur_logo     ;
                   
            jmp Fin                 ; sinon on va a la fin du programme
            
            
            rotation_logo:
                 
                 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         
               
                CMP mod_interacif, 1             ; si nous somme dans le mode interactif nous allons utiliser SI pour coller au mode fichier
                JE modinteractifrotation_logo
                 
                ;modfichier   
                
                MOV AX, OFFSET handle   ; lecture du fichier
                MOV DX, OFFSET buffer   ;
                MOV CX, 0003H           ;
                                        ;
                CALL  FAR PTR readFile  ; 
                mov SI,0
                
                modinteractifrotation_logo:
                
                mov bx,degres           ; bx = degres (degres = 0 au premier tour)
                
                mov al,buffer[SI+2]     ; on met dans al la valeur de la rotation
                sub al,30h              ;
                                                                    
                cmp buffer[SI+0],'G'    ; on regarde si on veut tourner a gauche
                    je tourner_gauche   ; ou a droite
                cmp buffer[SI+0],'D'    ;
                    je tourner_droite   ;
                      
                    
                tourner_droite:             ; si on veut tourner a droite
                  
                    
                    cmp al,1                ; on regarde la valeur de la rotation
                        je add_degres_45    ; puis on saute a l'etiquette correspondante
                    cmp al,2                ;
                        je add_degres_90    ;
                    cmp al,3                ;
                        je add_degres_135   ;
                    cmp al,4                ;
                        je add_degres_180   ;
                    cmp al,5                ;
                        je add_degres_225   ;
                    cmp al,6                ;
                        je add_degres_270   ;
                    cmp al,7                ;
                        je add_degres_315   ;
                    cmp al,8                ;
                        je add_degres_360   ;                    
 
                        
                tourner_gauche:             ; si on veut tourner a gauche
                
                
                    cmp al,1                ; on regarde la valeur de la rotation
                        je add_degres_315   ; puis on saute a l'etiquette correspondante
                    cmp al,2                ;
                        je add_degres_270   ;
                    cmp al,3                ;
                        je add_degres_225   ;
                    cmp al,4                ;
                        je add_degres_180   ;
                    cmp al,5                ;
                        je add_degres_135   ;
                    cmp al,6                ;
                        je add_degres_90    ;
                    cmp al,7                ;
                        je add_degres_45    ;
                    cmp al,8                ;
                        je add_degres_360   ;                 
                    
                                            
                add_degres_45:              ; etiquettes correspondante aux nombres de rotations
                    add bx,45               ; on ajoute la valeur correspondante a la rotation
                    jmp comparaison_360     ; puis on va sauter a l'etiquette de comparaison
                                            ;
                add_degres_90:              ;
                    add bx,90               ;
                    jmp comparaison_360     ;
                                            ;
                add_degres_135:             ;
                    add bx,135              ;
                    jmp comparaison_360     ;
                                            ;
                add_degres_180:             ;
                    add bx,180              ;
                    jmp comparaison_360     ;
                                            ;
                add_degres_225:             ;
                    add bx,225              ;
                    jmp comparaison_360     ;
                                            ;
                add_degres_270:             ;
                    add bx,270              ;
                    jmp comparaison_360     ;
                                            ;
                add_degres_315:             ;
                    add bx,270              ;
                    jmp comparaison_360     ;
                                            ;
                add_degres_360:             ;
                    add bx,360              ;
                    jmp comparaison_360     ;
        
    
                comparaison_360:                ; Etiquette de comparaison
                                                ;
                    cmp bx,360                  ; si bx (degres) est superieur a 360 degres (2 PI)
                        jge sub_degres_360      ; on va enlever 360 degres a bx
                        jmp fin_rotation_logo   ; sinon on saute a l'etiquette de fin
                                                ;
                        sub_degres_360:         ;                   
                            sub bx,360          ;
                        
                fin_rotation_logo:                     ; 
                                                       ;
                mov degres,bx                          ; on met dans la variable degres le contenu de bx
                jmp fin_analyse_et_stockage_du_fichier ; on saute a l'etiquette
                        
                       
                        
            deplacement_logo:            
                
                CMP mod_interacif, 1
                JE modinteractifdeplacement_logo               
                               
                
                MOV AX, OFFSET handle   ; lecture du fichier
                MOV DX, OFFSET buffer   ;
                MOV CX, 0005H           ;
                                        ;
                CALL  FAR PTR readFile  ;
                
                MOV SI, 0  
                
              modinteractifdeplacement_logo:
                
                mov passage_deplacement_logo,1  ; permet de savoir qu'on traite un deplacement
                
                mov reculer_info,0              
                 
                
                mov bl,10
            
                mov al,buffer[SI+2]  ; on recupere la longueur dans le fichier
                mul bl               ;
                add al,buffer[SI+3]  ;
                mul bl               ;
                add al,buffer[SI+4]  ;
                add ax,30h           ;
                                     ;
                mov ah,0             ;
                MOV Longueur, ax     ;
                
           
                cmp buffer[SI+0],'E'               ; on regarde si on veut reculer
                    je reculer                     ; si oui on saute a l'etiquette
                    jmp fin_deplacement_logo       ; sinon on saute a la fin 
                    
                reculer:                            ; on va donc reculer
                    mov ax,1                        ;
                    mov reculer_info,ax             ; on met notre variable a 1
                                                    ;
                    mov bx,degres                   ; puisqu'on recule c'est comme si on faisait
                    add bx,180                      ; un demi-tour (trigonometrie) donc +180 degres
                                                    ;
                    cmp bx,360                      ; on verifie qu'on a pas depasse 360 degres (2PI)
                            jge sub_degres_360_1    ; si oui on enleve 360 degres
                            jmp fin_reculer         ;
                                                    ;
                             sub_degres_360_1:      ;                      
                                 sub bx,360         ;
                                                    ;
                    fin_reculer:                    ;
                    mov degres,bx                   ; on remet a jour la variable degres
                    
                fin_deplacement_logo:
                jmp fin_analyse_et_stockage_du_fichier 
                
                
                
            couleur_logo:
         
                
                cmp buffer[2],'L'       ; Si on decide de lever le crayon
                    je lever_crayon     ; on saute a l'etiquette
                
                mov crayon,0
                
                CMP mod_interacif, 1
                JE modinteractifcouleur_logoBC 
                    
                         
                MOV AX, OFFSET handle   ; lecture du fichier
                MOV DX, OFFSET buffer   ;
                MOV CX, 0003H           ;
                                        ;
                CALL  FAR PTR readFile  ;       
                
                MOV SI,0
                
                modinteractifcouleur_logoBC:
                
                mov al, buffer[SI+2]        ; on  recupere  la  couleur  dans le  fichier
                cmp al, 40h                 ; si la couleur est  un  chiffre  en  decimal
                    jle inferieur_a_40_2    ; alors on saute a l'etiquette correspondante
                    jmp superieur_a_40_2    ; sinon la couleur est en hexadecimal
                                            ;
                    inferieur_a_40_2:       ;
                    sub al, 30H             ; on enleve 30h pour avoir la vraie valeur
                                            ;
                superieur_a_40_2:           ;
                mov ah,00h                  ;
                MOV Couleur, AX             ;
                jmp fin_couleur_logo 
                
                
                lever_crayon:           ; On leve le crayon
                                        ; en mettant la variable
                    mov ax,0001h        ; crayon a 1 (pour la suite)           
                    mov crayon,ax       ;
                    
                    CMP mod_interacif, 1
                    JE modinteractifcouleur_logoLC
                    
                    
                    MOV AX, OFFSET handle   ; lecture du fichier
                    MOV DX, OFFSET buffer   ;
                    MOV CX, 0001H           ;
                                            ;
                    CALL  FAR PTR readFile  ;       
                    
                    MOV SI,0
                  
                  modinteractifcouleur_logoLC:
                
                fin_couleur_logo:
                jmp fin_analyse_et_stockage_du_fichier 
                   
               
                    
        fin_analyse_et_stockage_du_fichier:
        
                
        cmp passage_deplacement_logo,1          ; si on a traiter un deplacement
            je all_passage_ok                   ; on va effectuer se deplacement
            jmp Recupere_donnee_dans_fichier    ; sinon on continue de traiter les lignes d'instructions
                        

                             
        all_passage_ok:
        
            mov passage_deplacement_logo,0      ; on remet la variable a 0     
                          
            Dessine:
                
                MOV     AX, Colonne   ; mise en registre
                MOV     BX, Ligne     ; des variables necessaire
                MOV     DX, Couleur   ; pour dessiner
                MOV     CX, Longueur  ;
                mov     si, degres    ;
                
                
                ; On va effectuer la prodecure correspondante
                ; au contenu de la vriable si (degres)
                ;
                
                cmp si,0000h    ;0 degres  
                    je Haut
                
                cmp si,002Dh    ;45   montante vers la droite
                    je Diago_MD    
                    
                cmp si,005Ah    ;90
                    je Droite
                    
                cmp si,0087h    ;135  descendante vers la droite
                    je Diago_DD
                
                cmp si,00B4h    ;180
                    je Bas
                    
                cmp si,00E1h    ;225  descendante vers la gauche
                    je Diago_DG
                
                cmp si,010Eh    ;270
                    je Gauche
    
                cmp si,013Bh    ;315  montante vers la gauche
                    je Diago_MG
                           
                
                jne Fin              ; sinon on saute a la fin du programme  
                
                    
            Droite:                                 ;
                mov si, crayon                      ; crayon : permet de savoir si on leve le crayon
                CALL FAR PTR DR                     ; appel de la procedure
                mov Colonne,ax                      ; on sauvegarde le deplacement effectuer
                mov Ligne,bx                        ;
                 cmp reculer_info,1                 ; si on a reculer on doit 
                    je retablir_degres_1            ; rajouter 180 a la variable  
                    jmp fin_droite                  ; degres  pour ne pas melanger
                retablir_degres_1:                  ; la gauche et la droite 
                mov ax,degres                       ;
                add ax,180                          ;
                mov degres,ax                       ;
                fin_droite:                         ; puis on va voir traiter les
                JMP Recupere_donnee_dans_fichier    ; lignes suivantes du fichier
                                                   
            Bas:                                    ;
                mov si, crayon                      ;             
                CALL FAR PTR BA                     ;
                mov Colonne,ax                      ;
                mov Ligne,bx                        ;
                cmp reculer_info,1                  ;
                    je retablir_degres_2            ;
                    jmp fin_bas                     ;
                retablir_degres_2:                  ;
                mov ax,degres                       ;
                add ax,180                          ;
                mov degres,ax                       ;
                fin_bas:                            ;
                JMP Recupere_donnee_dans_fichier    ;
                                                   
            Gauche:                                 ;
                mov si, crayon                      ;          
                CALL FAR PTR GA                     ;
                mov Colonne,ax                      ;
                mov Ligne,bx                        ;
                 cmp reculer_info,1                 ;
                    je retablir_degres_3            ;
                    jmp fin_gauche                  ;
                retablir_degres_3:                  ;
                mov ax,degres                       ;
                add ax,180                          ;
                mov degres,ax                       ;
                fin_gauche:                         ;
                JMP Recupere_donnee_dans_fichier    ;
                                                   
            Haut:                                   ;
                mov si, crayon                      ;            
                CALL FAR PTR HA                     ;
                mov Colonne,ax                      ;
                mov Ligne,bx                        ;
                 cmp reculer_info,1                 ;
                    je retablir_degres_4            ;
                    jmp fin_haut                    ;
                retablir_degres_4:                  ;
                mov ax,degres                       ;
                add ax,180                          ;
                mov degres,ax                       ;
                fin_haut:                           ;
                JMP Recupere_donnee_dans_fichier    ;
                
            Diago_MD:                               ;
                mov si, crayon                      ;            
                CALL FAR PTR DIAG_MD                ;
                mov Colonne,ax                      ;
                mov Ligne,bx                        ;
                 cmp reculer_info,1                 ;
                    je retablir_degres_5            ;
                    jmp fin_diago_md                ;
                retablir_degres_5:                  ;
                mov ax,degres                       ;
                add ax,180                          ;
                mov degres,ax                       ;
                fin_diago_md:                       ;
                JMP Recupere_donnee_dans_fichier    ;
                
            Diago_DD:                               ;
                mov si, crayon                      ;            
                CALL FAR PTR DIAG_DD                ;
                mov Colonne,ax                      ;
                mov Ligne,bx                        ;
                 cmp reculer_info,1                 ;
                    je retablir_degres_6            ;
                    jmp fin_diago_dd                ;
                retablir_degres_6:                  ;
                mov ax,degres                       ;
                add ax,180                          ;
                mov degres,ax                       ;
                fin_diago_dd:                       ;
                JMP Recupere_donnee_dans_fichier    ;
                
            Diago_DG:                               ;
                mov si, crayon                      ;            
                CALL FAR PTR DIAG_DG                ;
                mov Colonne,ax                      ;
                mov Ligne,bx                        ;
                 cmp reculer_info,1                 ;
                    je retablir_degres_7            ;
                    jmp fin_diago_dg                ;
                retablir_degres_7:                  ;
                mov ax,degres                       ;
                add ax,180                          ;
                mov degres,ax                       ;
                fin_diago_dg:                       ;
                JMP Recupere_donnee_dans_fichier    ;
            
            Diago_MG:                               ;
                mov si, crayon                      ;            
                CALL FAR PTR DIAG_MG                ;
                mov Colonne,ax                      ;
                mov Ligne,bx                        ;
                 cmp reculer_info,1                 ;
                    je retablir_degres_8            ;
                    jmp fin_diago_mg                ;
                retablir_degres_8:                  ;
                mov ax,degres                       ;
                add ax,180                          ;
                mov degres,ax                       ;
                fin_diago_mg:                       ;
                JMP Recupere_donnee_dans_fichier    ;    
            
    
Fin:
          
     MOV AX, OFFSET handle      ; fermeture du fichier      
     CALL  FAR PTR closeFile    ;          

ret
main3 endp





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;                                   ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;           MAIN ETAPE 2            ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;                                   ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main2 proc near
    
        
        
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
       
        choix_interactif_fichier2:   ; ici nous proposons a l'utilisateur de choisir entre le mode interactif et le mode de lecture dans un fichier

        MOV DX, OFFSET choix    ;
        MOV AH, 09H             ; l'affichage d'un menu
        INT 21H                 ;
        
        mov dx,offset message_choix     ; Veuillez entrer votre choix :
        mov ah,09h                      ;
        int 21h
        
        mov ah,01h                      ; l'utilisateur entre son choix
        int 21h                         ;        
        sub al,30h                      ;
        
        cmp al,1                        ; saut au choix correspondant
            je mode_interactif2         ;
        cmp al,2                        ;
            je OuvertureDeFichier2  
        
        jne erreur_choix                ; si le choix n'est pas valide 
       
        mode_interactif2: 
      
        MOV mod_interacif, 1     ; nous utiliserons une varaible mod_interactif afin de sauvegarder son choix
                               
        cree_fichier2:           ; le mode interactif, cree un fichier
            
            ; lecture du nom du chemin du repertoire
    	    ;   
    	    mov dx,offset message_cree_fichier
    	    mov ah,09h
    	    int 21h
    	
    	    MOV AX, 0A00H            ; 
            MOV DX, OFFSET filename  ; et nous recuperons son souhait dans un buffer de type chaine de caractere
            INT 21H                  ;
        
            MOV BL,filename[1]
            MOV filename[BX+2],0
            
            MOV AX, 3C00H               ; via l'interuption 3C->AH
	        MOV CX, 0000H               ; donnons l'attribut normal au fichier.
	        MOV DX, OFFSET filename+2   ; nom du fichier text.txt stoker dans chemin
	        INT 21H
	       
	        ;JC Erreur                  ; controle des erreur                  
            
            MOV handle, AX              ; l'endroit du fichier est sauvegarder dans la variable handle         
           
            CALL FAR PTR InitGraphe     ; nous passons en mode video
         
            JMP ecriture_dans_buffer2   ; nous pouvons maintenant proposer a l'utilisateur de participer               
        
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;    
       
        
        OuvertureDeFichier2:                  
        
        ; lecture du nom du chemin du repertoire
    	;
    	mov dx,offset message_entrer_fichier
    	mov ah,09h
    	int 21h
    	
    	MOV AX, 0A00H            ; 
        MOV DX, OFFSET filename  ; et nous recuperons son souhait dans un buffer de type chaine de caractere
        INT 21H                  ;
        
        MOV BL,filename[1]
        MOV filename[BX+2],0
        
        CALL FAR PTR InitGraphe         ; passage en mode video
         
            
        MOV AX, OFFSET handle               ; ouverture du fichier
        MOV DX, OFFSET filename+2           ;                                    
        CALL  openFile                      ;
        
        CMP mod_interacif, 0
        JE  Etape_2_Recupere_donnee_dans_fichier
      
      
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
      ecriture_dans_buffer2:         ; le mode interactif, fait participer l'utilisateur en ecrivant directement ce que doit faire le crayon
        
       
        MOV DX, OFFSET prompt       ; 
        MOV AX, 0900H               ; nous proposons a l'utilisateur d'ecrire
        INT 21H                     ;
        
        MOV AX, 0A00H                     ; 
        MOV DX, OFFSET buffer_interactif  ; et nous recuperons son souhait dans un buffer de type chaine de caractere
        INT 21H                           ;
        
        CMP buffer_interactif[2], 'Q'    ; si le choix est Q, nous quittons le programme
        JE Etape_2_Fin                   ;
        
      ecrirture_dans_fichier2:
      
        MOV DX, OFFSET buffer_interactif+2 ; ce buffer est compose a la premiere place, du nombre max de caractere qu'il peu stocker, a la seconde place, du nombre actuel de caracter qu'il a en stocke, et ensuite la chaine de caractere, nous passons donc +2 pour donner la chaine de caractere 
        MOV AX, 4000H                      ; interuption permetant d'ecrire dans un fichier
        MOV BX, handle                     ; nous passons en parametre le handle, endroit est le fichier et aussi endroit ou est le curseur dans le fichier
        MOV CH, 00H                        ; reinite ch a 0
        MOV CL, buffer_interactif[1]       ; dans ce buffer, au deuxieme emplacement, se trouve le nombre de caractere entrer par l'utilisateur 
        INT 21H
    
        ;JB Erreur 
         
        MOV SI,0 
         
      copie_buffer3:                       ; CX ayant le nombre de caracter en stock, et SI a 0
      
        MOV AH,buffer_interactif[SI+2]     ; nous allons copier la chaine de caractere du buffer interactif
        MOV buffer[SI],AH                  ; dans le buffer fichier afin d'utiliser les meme procedure dans le programme 'alege le code'
        INC SI                             ; par le biais d'une boucle en incrementant SI, pour parcourir les buffer et decrementant cx pour sortir de la boucle
        
        LOOP copie_buffer3
        
        
        JMP Etape_2_Analyse_et_stockage_du_fichier               ; nous pouvons maintenant traiter la demande de l'utilisateur

     ;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        
    Etape_2_Recupere_donnee_dans_fichier:
        
        CMP mod_interacif, 0       ;comme nous entrons dans une partie de code commune au deux mode, interactif et fichier, nous regardonc l'etat de la variable mod_interactif 
        JE modfichier2             ; si celle-ci est a 0, nous allons au mod fichier, sinon au mod interactif
     
           
       Position_curseur2:
        
        MOV DX, 0000H            ; 
        MOV AX, 0200H            ;
        INT 10H                  ;
                                 ; cette partie de code permet
        MOV DX, OFFSET prompt    ; de ne pas surchager l'ecran
        MOV AX, 0900H            ; des nombreuse commande
        INT 21H                  ; que pourrai enter l'utilisateur
                                 ;
        MOV DX, OFFSET propre    ;
        MOV AX, 0900H            ;
        INT 21H                  ;
                                 ;
        MOV DX, 000FH            ;
        MOV AX, 0200H            ;
        INT 10H                  ;
           
        interactifproc2:
     
      
        
        MOV AX, 0A00H                    ;
        MOV DX, OFFSET buffer_interactif ; recupere l'instruction de l'utilisateur
        INT 21H                          ;
        
        CMP buffer_interactif[2], 'Q'    ; si le choix est Q, nous quittons le programme
        JE Etape_2_Fin                   ;
      
  

        MOV DX, OFFSET buffer_retligne   ; nous retournons a la ligne
        MOV AX, 4000H                    ; dans le fichier
        MOV BX, handle                   ;
        MOV CX, 0002H                    ;  
        INT 21H                          ;
        
        
        MOV DX, OFFSET buffer_interactif+2 ;
        MOV AX, 4000H                      ; puis nous y ecrivons son instruction
        MOV BX, handle                     ;
        MOV CH, 00H                        ;
        MOV CL, buffer_interactif[1]       ;  
        INT 21H
    
        ;JB Erreur 
        
        MOV SI,0
         
      copie_buffer4:
      
        MOV AH,buffer_interactif[SI+2]       ; 
        MOV buffer[SI],AH                  ; copier le buffer interactif dans le buffer
        INC SI                             ;
                                           ;
        LOOP copie_buffer4                 ;
                                           
                                 ; met SI a 3 afin de coller au mod fichier
        
        JMP Etape_2_Analyse_et_stockage_du_fichier ; nous allons maintenant traiter la demande de l'utilisateur comme si elle ete ecrite dans un fichier   
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                 
    
     modfichier2:
        
            MOV AX, OFFSET handle           ; lecture du fichier
            MOV DX, OFFSET buffer           ;
            MOV CX, 0011H                   ;
                                            ;
     
     
            CALL  FAR PTR readFile          ; passage en mode video
        
        Etape_2_Analyse_et_stockage_du_fichier:
            
                MOV SI, 0
                MOV AL, buffer[0]       ; on recupere le "type" dans le fichier 
                MOV AH, 00H             ;
                MOV Tipe, AX            ;
                
                mov bl,10               ; bx : coefficient multiplicateur = 10
                
                mov al,buffer[2]        ; on prend le chiffre des centaine : 1__
                mul bl                  ; on le multiplie par 10           : 10
                add al,buffer[3]        ; on ajoute le chiffre des dizaine : _1_
                mul bl                  ; on le multiplie par 10           : 110
                add al,buffer[4]        ; on ajoute le chiffre des unite   : __1
                add ax,30h              ; on ajoute 30h pour avoir un resultat utilisable
                                        ; resultat : 111
                mov ah,0                ;
                MOV Ligne, ax           ; on met le resultat dans la variable Ligne
               
                
                mov al,buffer[6]        ; on recupere dans le fichier le nombre
                mul bl                  ; correspondant a la colonne
                add al,buffer[7]        ;
                mul bl                  ;
                add al,buffer[8]        ;
                add ax,30h              ;
                                        ;                             
                mov ah,0                ; 
                MOV Colonne, ax         ; on met le resultat dans la variable Colonne  
                
                
                mov al, buffer[10]              ; on  recupere  la  couleur  dans le  fichier
                cmp al, 40h                     ; si la couleur est  un  chiffre  en  decimal
                    jle Etape_2_inferieur_a_40  ; alors on saute a l'etiquette correspondante
                    jmp Etape_2_superieur_a_40  ; sinon la couleur est en hexadecimal
                                                ;
                    Etape_2_inferieur_a_40:     ;
                    sub al, 30H                 ; on enleve 30h pour avoir la vraie valeur
                                                ;
                Etape_2_superieur_a_40:         ;
                mov ah,00h                      ;
                MOV Couleur, AX                 ;
                
                mov al,buffer[12]               ; on recupere la longueur dans le fichier
                mul bl                          ;
                add al,buffer[13]               ;
                mul bl                          ;
                add al,buffer[14]               ;
                add ax,30h                      ;
                                                ;
                mov ah,0                        ;     
                MOV Longueur, ax                ;
                
            
                MOV CX,20                       ; apres  avoir  assigne les valeurs du   
                MOV SI,0                        ; fichier  dans nos variables, on vide               
            Etape_2_reinite_buffer:             ; le buffer pour pouvoir le reutiliser
                                                ; si  on  a  plusieurs  lignes dans le
                MOV buffer[SI], ' '             ; fichier
                INC SI                          ;
                                                ;
                LOOP Etape_2_reinite_buffer     ;  
            
            Etape_2_Dessine:
                
                MOV     AX, Colonne
                MOV     BX, Ligne
                MOV     DX, Couleur
                MOV     CX, Longueur 
                
                CMP Tipe,'D'                    ; on vient comparer le "type"  
                    JE Etape_2_Droite           ; avec  les  lettres attendue
                                                ; et on  saute a  l'etiquette
                CMP Tipe,'B'                    ; correspondante
                    JE Etape_2_Bas              ;
                                                ;
                CMP Tipe,'G'                    ;
                    JE Etape_2_Gauche           ;
                                                ;
                CMP Tipe,'H'                    ;
                    JE Etape_2_Haut             ;
                
                JNE Etape_2_Fin                 ; sinon on saute a la fin du programme  
                
                    
            Etape_2_Droite:
		        mov si,0                                    ; appel des procedures  correspondante
                CALL FAR PTR DR                             ; si on a demander l'etape 1 
                cmp passage_main_etape1,1                   ; on ne lit pas le reste du fichier
                    je Etape_2_Fin                          ; sinon on lit le reste du fichier
                                                            ;
                JMP Etape_2_Recupere_donnee_dans_fichier    ;
                                                            
            Etape_2_Bas:
		        mov si,0                                    ;
                CALL FAR PTR BA                             ;
                cmp passage_main_etape1,1                   ;
                    je Etape_2_Fin                          ;
                                                            ;
                JMP Etape_2_Recupere_donnee_dans_fichier    ;
                                                   
            Etape_2_Gauche:
		        mov si,0                                    ;
                CALL  FAR PTR GA                            ;
                cmp passage_main_etape1,1                   ;
                    je Etape_2_Fin                          ;
                                            ;               ;
                JMP Etape_2_Recupere_donnee_dans_fichier    ;
                                                   
            Etape_2_Haut:                                   
		        mov si,0                                    ;
                CALL  FAR PTR HA                            ;
                cmp passage_main_etape1,1                   ;
                    je Etape_2_Fin                          ;
                                                            ;
                JMP Etape_2_Recupere_donnee_dans_fichier    ;
    
Etape_2_Fin:
          
     MOV AX, OFFSET handle      ; fermeture du fichier      
     CALL  FAR PTR closeFile    ;
                                                

ret        
main2 endp
     

        
CODE ENDS
END main 