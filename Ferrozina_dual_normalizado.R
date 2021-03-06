library("pacman")
p_load("vroom",
       "dplyr",
       "ggplot2",
       "ggsci" ,
       "agricolae", #para poder agrupar el Tukey
       "ggpubr",   #gr�ficas simplificadas
       "RVAideMemoire", #Prueva shapiro
       "car",#para igualdad de varianzas
       "tidyverse",
       "scales") #para poner coma en los miles

datos_dual <- vroom(file = "https://raw.githubusercontent.com/ManuelLaraMVZ/Ferrozina_dual/main/Ferrocina_dual.csv")
head(datos_dual)

datos_dual

datos_dual$Tratamiento <- factor(datos_dual$Tratamiento, 
                                 levels = c("WT","DMSO", "0.9 �M 8-HQ", "tGAS1", "tGAS1+0.9 �M 8-HQ","eGFP" ))
head(datos_dual )

datos_dual2 <- datos_dual %>% 
  select(Tratamiento, Valores)  %>% 
  group_by(Tratamiento) %>% 
  filter(Valores<1.2)


datos_dual2

resumen_dual <- datos_dual2 %>% 
  group_by(Tratamiento) %>% #decimos cuales son nuestros factores
  get_summary_stats(type = "mean_sd") %>% #obtenemos la tabla
  select(Tratamiento, n, mean, sd) %>% 
  mutate(se=sd/(n^(1/2)))
resumen_dual

###################################################################################

#visualizamos la distribuci�n
caja1 <- datos_dual2 %>% 
  ggboxplot(x="Tratamiento",
            y="U.A.2.",
            color="Tratamiento",
            palette = "jco")
caja1

modelo <- lm(Valores~Tratamiento, data = datos_dual2)
ggqqplot(residuals(modelo))

#####################################3

resumen_dual

grafica_dual <- resumen_dual%>% 
  ggplot(mapping = aes(x=Tratamiento,
                       y=mean,
                       fill="Tratamiento"))+
  geom_col()

grafica_dual

byf.shapiro(U.A.2~Tratamiento, data=datos_dual2)

leveneTest(U.A.2~Tratamiento, data=datos_dual2)
fligner.test(U.A.2~Tratamiento, data=datos_dual2)
bartlett.test(U.A.2~Tratamiento, data=datos_dual2)

#Pasa prueba de normalidad para levene y fligner

#Podemos proceer con el ANOVa

###############################33

ANOVA_dual<- aov( Valores~Tratamiento,data = datos_dual2) #Ponemos de donde se sacan los datos y luego la relaci�n

#Visualizamos
ANOVA_dual
#obtenemos la tabla e anova
summary.aov(ANOVA_dual)

#Existe diferencia entre los tratamientos

#obtenemos las similitudes

agrupados_dual <- HSD.test(ANOVA_dual,"Tratamiento", group=T, console=T,
                           main = "Celulas con tratamiento dual: MC y 8-OH")

agrupados_dual

#Hay que tomar los datos y copiarlos en un txt para poder realizar el an�lisis

similitud <- c("a","ab","b","b","c") #se construye con los resultados de las interacciones

resumen_dual

resumen_dual_ANOVA <- resumen_dual %>% 
  select(Tratamiento, n, mean, sd,se) %>% 
  mutate(similitud)

resumen_dual_ANOVA
################################################################################



Grafica_datos <- resumen_dual_ANOVA

Grafica_datos

barras1 <- Grafica_datos %>% 
  ggplot(mapping = aes(x=Tratamiento,
                       y=mean,
                       fill=Tratamiento))+
  geom_bar(stat = "identity", colour="black", size=.8)+
  theme_classic()+
  scale_fill_d3()+
  theme_light()

barras1

miny=0
maxy=1.1


marcasy <- seq(from=miny,
               to=maxy,
               by=0.2)


barras2 <- barras1+
  scale_y_continuous(limits=c(miny,maxy), #colocamos los l�mites del eje y
                     breaks=marcasy,
                     expand=c(0,0),
                     labels = comma)+
  theme(legend.position="right")+ #empezamos a meter lo que le pusimos
  theme(axis.text.x = element_blank())+
  theme(axis.ticks.x = element_blank())+
  theme(axis.line = element_line(size = 0.8))+
  theme(axis.ticks.x = element_line(size = 0.8))+
  theme(axis.ticks.y = element_line(size = 0.8))+
  theme(legend.title= element_blank())+
  
  theme(legend.text = element_text(size = 16, face = "bold"))+
  theme(axis.title.x = element_text(size=16, face="bold"))+
  theme(axis.title.y = element_text(size=16, face="bold"))+
  theme(axis.text.y = element_text(size=16, face = "bold"))+
  theme(axis.ticks.x.bottom = element_blank())+
  
  geom_errorbar( aes(ymin=mean-se, 
                     ymax=mean+se), 
                 width=0.2, colour="black", alpha=1, size=.8)+
  xlab("Treatment")+
  ylab("Iron concentration (p.d.u.)")+
  
  
  geom_text(aes(label=similitud),
            nudge_x=0.25,     #REspecto al eje x que tanto cambia
            nudge_y =0.05,      #respecto al eje y que tanto cambia
            size=6,
            face="bold")+
  scale_fill_simpsons()+
  
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank())

barras2

ggsave(filename = "Tratamiento_dual_normalizado.png",
       plot = barras2,
       dpi = 600,
       height = 5,
       width = 9) 

#si queremos la gr�fica sin gradillas ni borde poner lo siguiente
#+   theme(
# panel.grid.major = element_blank(),
# panel.grid.minor = element_blank(),
#panel.border = element_blank())

barras3 <- barras2+
  scale_fill_grey()
barras3 

ggsave(filename = "Tratamiento_dual_normalizadogris.png",
       plot = barras3,
       dpi = 600,
       height = 5,
       width = 9) 


