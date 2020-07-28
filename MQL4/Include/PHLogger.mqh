/ / | - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |                                                                                                           P H L o g g e r . m q 4   |  
 / / |                                                                         C o p y r i g h t   �   2 0 2 0 ,   H e a r M o n s t e r   |  
 / / |                                                                                   m a i l t o : h e a r m o n s t e r @ p m . m e   |  
 / / | - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 # p r o p e r t y   c o p y r i g h t   " C o p y r i g h t   �   2 0 2 0 ,   H e a r M o n s t e r "  
 # p r o p e r t y   l i n k             " m a i l t o : h e a r m o n s t e r @ p m . m e "  
 # p r o p e r t y   s t r i c t  
  
 # d e f i n e   L L P (   _ t h r e s h o l d )   s t r i n g   s L L P   =   S t r i n g S u b s t r ( _ _ F I L E _ _ , 0 , S t r i n g L e n ( _ _ F I L E _ _ ) - 4 )   +   " : : "   +   _ _ F U N C T I O N _ _   +   " : : " ;   e L o g L e v e l s   e L T   =   _ t h r e s h o l d ;     / /   L o g   L i n e   P r e f i x   &   L o g   T h r e s h o l d  
 # d e f i n e   l o g A L L (   _ t e x t   )       l o g W r i t e (   L O G _ A L L ,   e L T ,   s L L P ,   _ t e x t   ) ;  
 # d e f i n e   l o g F A T A L (   _ t e x t   )   l o g W r i t e (   L O G _ F A T A L ,   e L T ,   s L L P ,   _ t e x t   ) ;  
 # d e f i n e   l o g E R R O R (   _ t e x t   )   l o g W r i t e (   L O G _ E R R O R ,   e L T ,   s L L P ,   _ t e x t   ) ;  
 # d e f i n e   l o g I N F O (   _ t e x t   )     l o g W r i t e (   L O G _ I N F O ,     e L T ,   s L L P ,   _ t e x t   ) ;  
 # d e f i n e   l o g D E B U G (   _ t e x t   )   l o g W r i t e (   L O G _ D E B U G ,   e L T ,   s L L P ,   _ t e x t   ) ;  
  
  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |     H O W   D O   I   U S E   T H I S ?  
 / / |  
 / / |     P l a c e   t h e s e   t w o   l i n e s   t o w a r d s   t h e   t o p   o f   y o u r   c o d e :    
 / / |         ( t h e   # i n c l u d e   b e l o n g s   a t   t h e   h e a d   o f   t h e   c o d e ,   a n d   t h e   o t h e r   l i n e   i s   a  
 / / |           d e c l a r a t i o n   o f   a   g l o b a l   v a r i a b l e   -   s o   t h a t   b e l o n g s   a t   t h e   t o p   a n y w a y )  
 / / |  
 / *  
  
       # i n c l u d e   < P H L o g g e r . m q h >  
  
 * /  
 / / |  
 / / |     N o t e   t h a t   t h e   i n c l u d e d   h e a d e r   f i l e   a c t u a l l y   i n s t a n t i a t e s   a n   i n s t a n c e   o f   m y   P H L o g g e r   c l a s s   f o r   y o u ,   n a m e d   " m y L o g g e r "  
 / / |     T h e n   w h e n e v e r   y o u   w a n t   t o   w r i t e   t o   t h e   l o g ,   u s e   s o m e t h i n g   l i k e :  
 / / |  
 / *  
  
       m y L o g g e r . l o g I N F O (   " B a r s :   "   +   s t r i n g ( B a r s )   ) ;  
  
 * /  
 / / |       A s i d e :   Y o u   w o n ' t   a c t u a l l y   f i n d   a n y   m e t h o d s   n a m e d ,   L O G x x x x ,   t h e y ' r e   a c t u a l l y   M a c r o s   t h a t   c o n v e n i e n t l y    
 / / |             s e t   a   w h o l e   b u n c h   o f   p a r a m e t e r s   f o r   y o u ,   l e a v i n g   y o u   j u s t   t o   s u p p l y   * o n l y *   t h e   m e s s a g e   t e x t !  
 / / |  
 / / |     < R E C O M M E N D E D > :  
 / / |     P l a c e   a   l i n e   s i m i l a r   t o   t h i s   a t   t h e   s t a r t   o f   * e v e r y ) *   m e t h o d .   I t   w i l l   s e t  
 / / |       a )   t h e   L o g   L i n e   P r e f i x   ( i . e .   t h e   f i l e   a n d   f u n c t i o n   n a m e )   a u t o m a t i c a l l y   f o r   y o u  
 / / |       b )   t h e   t h r e s h o l d   f o r   t h i s   f u n c t i o n   ( a n y   m e s s a g e s   e q u a l   t o ,   o r   m o r e   s e v e r e   t h a n   t h i s   w i l l   a p p e a r   i n   t h e   l o g )  
 / / |  
 / *  
  
       L L P (   L O G _ I N F O   )   / / L o g   F i l e   P r e f i x  
  
 * /  
 / / |  
 / / |     T h e r e ' s   n o   n e e d   t o   c l e a n   i t   u p   i n   t h e   D e I n i t ( )   -   i t ' l l   c l e a n   i t s e l f   u p  
 / / |  
 / / |     < R E C O M M E N D E D >   F o r   a n y t h i n g   o t h e r   t h a n   a   s h o r t - r u n n i n g   s c r i p t ,   s e t   u p   a   t i m e r   t o   f l u s h   t h e   l o g  
 / / |                                 ( A   s h o r t - r u n n i n g   s c r i p t   w i l l   f l u s h   i t ' s   l o g   f i l e   a t   c o m p l e t i o n   a u t o m a t i c a l l y )  
 / / |  
 / *  
  
     i n t   O n I n i t ( )   {  
             / / - - -   c r e a t e   t i m e r   ( u s e d   f o r   f l u s h i n g   t h e   l o g   f i l e )  
             E v e n t S e t T i m e r ( 2 ) ;  
             . . .  
  
       v o i d   O n D e i n i t ( c o n s t   i n t   r e a s o n )  
           {  
             / / - - -   d e s t r o y   t i m e r  
             E v e n t K i l l T i m e r ( ) ;  
             . . .  
  
       v o i d   O n T i m e r ( )  
           {  
             m y L o g g e r . f i l e F l u s h ( ) ;  
             . . .  
  
 * /  
 / / |  
 / / |  
  
  
  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |     W H E R E   D O   T H E   ( L O G )   F I L E S   G E T   W R I T T E N ?  
 / / |  
 / / |   T h e   T e r m i n a l   i s   i n s t a l l e d   i n t o :  
 / / |   C : \ U s e r s \ i 8 1 7 3 9 9 \ A p p D a t a \ R o a m i n g \ M e t a Q u o t e s \ T e r m i n a l \ F 2 2 6 2 C F A F F 4 7 C 2 7 8 8 7 3 8 9 D A B 2 8 5 2 3 5 1 A  
 / / |   ( I ' l l   r e f e r   t o   t h i s   a s   < T E R M I N A L _ H O M E >   b e l o w )  
 / / |  
 / / |   W H I C H   D I R E T C T O R Y ?  
 / / |   T h e   * D i r e c t o r y *   i n   w h i c h   t h e   f i l e   w i l l   b e   c r e a t e d :  
 / / |         W h e n   r u n   a s   a   * S c r i p t * :                   < T E R M I N A L _ H O M E > \ M Q L 4 \ F i l e s  
 / / |         W h e n   r u n   a s   a n   * E x p e r t * :                 < T E R M I N A L _ H O M E > \ M Q L 4 \ F i l e s  
 / / |         B u t   w h e n   r u n   u n d e r   t h e   T e s t e r :     < T E R M I N A L _ H O M E > \ T e s t e r \ f i l e s \ "  
 / / |  
 / / |   U N D E R   W H A T   F I L E N A M E ?  
 / / |   T h e   f i l e   n a m e   w i l l   b e :  
 / / |     < E x p e r t   N a m e > ( < S y m b o l > ~ < P e r i o d > ) . l o g       e . g .   " P H T i c k T e s t ( E U R U S D ~ M 1 ) . l o g "  
 / / |  
 / / |       W h e n   e x e c u t e d   u n d e r   t h e   M e t a E d i t o r ,   c h e c k   T o o l s   > >   O p t i o n s   > >   D e b u g   [ t a b ]   f o r   t h e   < S y m b o l >   a n d   < P e r i o d >  
 / / |       W h e n   e x e c u t e d   u n d e r   t h e   T e r m i n a l   T E S T E R ,   s e e   t h e   < S y m b o l >   a n d   < P e r i o d >   f i e l d s  
 / / |  
 / / |   F Y I   R e m e m b e r   t h a t   y o u   * a l s o *   h a v e  
 / / |       a )   S c r i p t / E x p e r t   L o g   f i l e s   ( t h e   r e s u l t   o f   ' P r i n t '   f u n c t i o n s )   u n d e r   " . . . \ M e t a T r a d e r   4 \ e x p e r t s \ l o g s \ "  
 / / |       b )   T e s t e r   L o g   f i l e s   ( l o a d i n g   o f   e x 4   s c r i p t s   +   t h e   r e s u l t   o f   t r a d e   o p e n s   &   c l o s e s )   u n d e r   " . . . \ M e t a T r a d e r   4 \ e x p e r t s \ l o g s \ "  
 / / |       c )   M T 4   S y s t e m   L o g   f i l e s   ( t h e   r e s u l t   o f   t r a d e s )   u n d e r   " . . . \ M e t a T r a d e r   4 \ l o g s \ "  
 / / |  
 / / |   " P r i n t "   c o m m a n d s   g e t   w r i t t e n   t o   < T E R M I N A L _ H O M E > \ M Q L 4 \ L o g s \ < Y Y Y Y M M D D > . l o g "  
 / / |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   W H E N   D O   T H E   L I N E S   G E T   A P P E N D E D ?   ( W h e n   w i l l   m y   l i n e s   a p p e a r   i n   t h e   f i l e ? )  
 / / |  
 / / |   F l u s h i n g   a p p e a r s   t o   b e   a   d e f i n i t e   i s s u e   w i t h   M T 4 !     : o (  
 / / |  
 / / |   S o   I ' v e   a l l o w e d   y o u   t o   s p e c i f y   a   c o u n t e r   -   w h i c h   f l u s h e s   t h e   l o g   f i l e   e x e r y    
 / / |       ' x '   r o w s   a p p e n d e d  
 / / |  
 / / |   Y o u   c a n   a l s o   s e t   u p   t h e   T i m e r   ( i n   y o u r   c a l l i n g   s c r i p t ' s   I N I T   m e t h o d )   t o    
 / / |       e x p l i c i t l y   c a l l   m y   F l u s h ( )   m e t h o d   e v e r y   ' x '   s e c o n d s  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   H O W   D O   T H E   L I N E S   G E T   A P P E N D E D ?   ( i . e .   U n d e r   w h a t   c o n d i t i o n s ? )  
 / / |  
 / / |   W i l l   o n l y   w r i t e   i f   t h e   M e s s a g e L e v e l   i s   * m o r e   s e r i o u s *   i . e   a   l o w e r   v a l u e  
 / / |     t h a n   t h e   c a l l i n g   f u n c t i o n ' s   T h r e s h o l d  
 / / |  
 / / |   N o t e   t h a t   t h e   L O G _ O F F   w i l l   a l m o s t   * c o m p l e t e l y   d i s a b l e *   t h e   l o g s !  
 / / |     -   A b s o l u t e l y   * n o   l o g s *   w i l l   b e   w r i t t e n   i r r e s p e c t i v e   o f   t h e   s e r i o u s n e s s  
 / / |     -   E v e n   a t t e m p t i n g   t o   w r i t e   a   L O G _ F A T A L   w i l l   * n o t *   g e t   w r i t t e n !  
 / / |     -   H o w e v e r ,   s e n d i n g   a   l o g   w i t h   a   M e s s a g e L e v e l   o f   L O G _ O F F   w i l l   a l w a y s  
 / / |         a p p e a r   i n   t h e   l o g s  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
  
 e n u m   e L o g L e v e l s     / /   e n u m e r a t i o n   o f   n a m e d   c o n s t a n t s    
     {   L O G _ O F F       =   0 ,  
         L O G _ F A T A L   =   1 ,  
         L O G _ E R R O R   =   2 ,  
         L O G _ W A R N   =   3 ,  
         L O G _ I N F O   =   4 ,  
         L O G _ D E B U G   =   5  
     } ;  
  
  
  
  
 # i n c l u d e   < P H F i l e P r i n t e r . m q h >             / / B a s e   C l a s s  
  
 c l a s s   P H L o g g e r   :   p u b l i c   P H F i l e P r i n t e r   {  
  
       p r i v a t e :  
             / / < < < p r i v a t e   a t t r i b u t e s > > >  
             i n t             _ n L o g F a t a l C o u n t ,   _ n L o g E r r o r C o u n t ,   _ n L o g W a r n C o u n t ;         / / E n d   o f   t r a c e   S t a t i s t i c s   ( u s e d   b y   ' l o g ( ) '   a n d   ' l o g _ c l o s e ( ) '   f u n c t i o n s )  
             s t r i n g       _ s F i l e n a m e ;  
  
       p u b l i c :  
             / / < < < C o n s t r u c t o r s > > >  
                               P H L o g g e r   ( ) ;  
                               ~ P H L o g g e r ( )   {   f i l e P r i n t (   " L o g   f i l e   c l o s i n g . "   ) ;   }  
  
             / / < < < p u b l i c   m e t h o d s > > >  
             v o i d           l o g P r i n t S u m m a r y S t a t s ( ) ;  
             v o i d           l o g W r i t e (   e L o g L e v e l s   e M e s s a g e L e v e l ,   e L o g L e v e l s   e L o g T h r e s h o l d ,   s t r i n g   s L o g P r e f i x ,   s t r i n g   t e x t     ) ;  
 / *  
 T h e s e   ' c o n v e n i e n c e '   m e t h o d s   d o n ' t   a c t u a l l y   e x i s t ,   b u t   c a n   b e   c a l l e d   l i k e   t h i s   b e c a u s e   o f   t h e   m a c r o s   I ' v e   d e f i n e d   a b o v e  
             v o i d           l o g F A T A L (   s t r i n g   t e x t     ) ;  
             v o i d           l o g E R R O R (   s t r i n g   t e x t     ) ;  
             v o i d           l o g I N F O (     s t r i n g   t e x t     ) ;  
             v o i d           l o g W A R N (     s t r i n g   t e x t     ) ;  
             v o i d           l o g D E B U G (   s t r i n g   t e x t     ) ;  
 * /  
              
 } ;   / /   e n d   c l a s s   H E A D E R  
  
  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |       C o n s t r u c t o r  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 v o i d   P H L o g g e r : : P H L o g g e r ( )   {  
 / /   W e   n e e d :  
 / /         1 .   A   f i l e n a m e   -   a u t o   c o n s t r u c t e d   b e l o w   [ _ s F i l e n a m e ]  
 / /         2 .   ( o p t i o n a l )   A   l o g   l e v e l   [ n L o g L e v e l P a r a m ]  
  
  
       / /   C o n s t r u c t   t h e   l o g   f i l e n a m e :     < E x p e r t N a m e >   | |   " ( "   | |   < S y m b o l   P a i r >   | |   " ~ "   | |   < P e r i o d >   | |   " ) . l o g "  
       s t r i n g   s W i n d o w P e r i o d   =   S t r i n g S u b s t r (   E n u m T o S t r i n g (   C h a r t P e r i o d (   0   )   ) ,   7   ) ;   / /   C h a r t P e r i o d (   0   )   =   C u r r e n t   c h a r t .   E n u m T o S t r i n g ( )   w i l l   r e t u r n   e . g .   " P E R I O D _ D 1 "   f o r   D A I L Y  
       s t r i n g   s C u r r e n c y P a i r   =   C h a r t S y m b o l (   0   ) ;     / /   C h a r t S y m b o l (   0   )   =   C u r r e n t   c h a r t .   R e t u r n s   s t r i n g  
       _ s F i l e n a m e   =   W i n d o w E x p e r t N a m e ( )   +   " ( "   +   s C u r r e n c y P a i r   +   " ~ "   +   s W i n d o w P e r i o d   +   " ) . l o g " ;  
  
       / / U n l i k e   t h e   B a s e   C l a s s ,   w e   c a n   t a k e   t h e   o p p o r t u n i t y   t o   o p e n   t h e   f i l e   i m p l i c i t l y   ( b e c a u s e   w e ' v e   a u t o m a t i c a l l y   c o n s t r u c t e d   t h e   f i l e n a m e ) ,   w i t h o u t   t h e   n e e d   f o r   a   ' l o g O p e n '   c a l l  
       f i l e O p e n (   _ s F i l e n a m e   ) ;  
  
       / / E n d   o f   t r a c e   S t a t i s t i c s   ( u s e d   b y   ' l o g ( ) '   a n d   ' l o g _ c l o s e ( ) '   f u n c t i o n s )  
       _ n L o g F a t a l C o u n t   =   0 ;  
       _ n L o g E r r o r C o u n t   =   0 ;  
       _ n L o g W a r n C o u n t     =   0 ;          
  
 }  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |       D e s s t r u c t o r  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / *  
 v o i d   P H L o g g e r : : ~ P H L o g g e r ( )   {  
  
             f i l e P r i n t (   " L o g   f i l e   c l o s i n g . "   ) ;  
 }  
 * /  
  
  
  
  
  
 / / | - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |     P r i n t   S u m m a r y   S t a t s  
 / / |       C o u n t   o f   F a t a l s ,   E r r o r s   a n d   W a r n i n g s  
 / / | - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 v o i d   P H L o g g e r : : l o g P r i n t S u m m a r y S t a t s ( )   {  
  
       f i l e P r i n t (   " F i n a l   c o u n t   o f   F A T A L   l o g s :   "   +   s t r i n g ( _ n L o g F a t a l C o u n t )   ) ;  
       f i l e P r i n t (   " F i n a l   c o u n t   o f   E R R O R   l o g s :   "   +   s t r i n g ( _ n L o g E r r o r C o u n t )   ) ;  
       f i l e P r i n t (   " F i n a l   c o u n t   o f   W A R N   l o g s :     "   +   s t r i n g ( _ n L o g W a r n C o u n t )   ) ;  
 }  
            
  
  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / /   W r i t e   a   l i n e   o f   t e x t   t o   t h e   m e s s a g e   f i l e . . .  
 / /  
 / /   . . . a s s u m i n g   i t ' s   s e v e r i t y   i s   m o r e   s e r i o u s   t h a n   t h e   c a l l i n g    
 / /   f u n c t i o n ' s   l o c a l   l e v e l  
 / /   ( a c t u a l l y ,   w e   l o o k   f o r   a   * l o w e r   t h a n   o r   e q u a l   t o *   t h r e s h o l d )  
 / /  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 v o i d   P H L o g g e r : : l o g W r i t e (   e L o g L e v e l s   e M e s s a g e L e v e l ,   e L o g L e v e l s   e L o g T h r e s h o l d ,   s t r i n g   s L o g P r e f i x ,   s t r i n g   t e x t     )   {  
  
 	 / / I f   i n v a l i d   f i l e   h a n d l e   t h e n   A b o r t !  
 	 i f   (   i F i l e H a n d l e   = =   I N V A L I D _ H A N D L E   ) 	 {  
 	 	 P r i n t (   " L o g   w r i t e   e r r o r !   T e x t :   " ,   t e x t   ) ;  
             / / ' P r i n t '   -   s e e   m y   n o t e   a b o v e   a b o u t   w h e r e   " P r i n t "   c o m m a n d s   g e t   w r i t t e n  
 	 	 r e t u r n ;  
 	 }  
  
       / / I n c r e m e n t   S t a t i s t i c s   -   o n l y u   a p p l i c a b l e   f o r   F A T A L ,   E R R O R   a n d   W A R N   m e s s a g e s  
 	 s w i t c h   (   e M e s s a g e L e v e l   )  
 	 {  
 	 	 c a s e   L O G _ O F F :       b r e a k ;  
 	 	 c a s e   L O G _ F A T A L :   _ n L o g F a t a l C o u n t + + ;   b r e a k ;  
 	 	 c a s e   L O G _ E R R O R :   _ n L o g E r r o r C o u n t + + ;   b r e a k ;  
 	 	 c a s e   L O G _ W A R N :     _ n L o g W a r n C o u n t + + ;   b r e a k ;  
 	 	 c a s e   L O G _ I N F O :     b r e a k ;  
 	 	 c a s e   L O G _ D E B U G :   b r e a k ;  
 	 	 d e f a u l t : 	 	         b r e a k ;  
 	 }   / / e n d   s w i t c h  
        
       / / O n l y   w r i t e   i f   t h e   M e s s a g e L e v e l   i s   m o r e   s e r i o u s   t h a n   t h e   t w o   T h r e s h o l d s   ( t h e   G l o b a l   T h r e s h o l d ,   O R   t h e   c a l l i n g   f u n c t i o n ' s   T h r e s h o l d )  
       / / i f   (   ( n M e s s a g e L e v e l   < =   n G l o b a l L o g L e v e l T h r e s h o l d )   | |   ( n M e s s a g e L e v e l   < =   n F u n c t i o _ n L o g L e v e l T h r e s h o l d )   )   {  
       / / O n l y   w r i t e   i f   t h e   M e s s a g e L e v e l   i s   m o r e   s e r i o u s   t h a n   t h e   c a l l i n g   f u n c t i o n ' s   T h r e s h o l d  
       i f   ( e M e s s a g e L e v e l   < =   e L o g T h r e s h o l d   )   {  
        
             / / P r e f i x   t h e   l i n e   w i t h   t h e   L o g   L e v e l ,   a n y   F I L E   a n d / o r   F U N C T I O N   p r e f i x   ( s p e c i f i e d ) .     T h e   F i l e P r i n t e r   p r e f i x e s   a l l   o f   i t   w i t h   t h e   d a t e t i m e .  
             s L o g P r e f i x   =     S t r i n g S u b s t r (   E n u m T o S t r i n g (   e M e s s a g e L e v e l   ) ,   4   )   +   " : : "   +   s L o g P r e f i x ;  
             f i l e P r i n t (   s L o g P r e f i x   +   t e x t   ) ;  
       }  
              
 }  
  
  
 / / < < < G l o b a l   V a r i a b l e s > > >  
 / / I n s t a n c i a t e   a n   i n s t a n c e   o f   m y   P H L o g g e r   c l a s s   f o r   y o u r   c o n v e n i e n c e ,   n a m e d   " m y L o g g e r "  
 P H L o g g e r   m y L o g g e r ( ) ;  
  
 