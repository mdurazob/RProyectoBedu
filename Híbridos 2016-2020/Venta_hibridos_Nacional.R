
# Registro Administrativo de la Industria Automotriz de Veh�culos Ligeros. 
#Venta de veh�culos h�bridos y el�ctricos a nivel nacional en el periodo 2016 Ene -2020 Oct. 

#Los datos mostrados a continuaci�n fueron obtenidos de:
# INEGI. Datos primarios, Registro administrativo de la industria automotriz de veh�culos ligeros
# https://www.inegi.org.mx/datosprimarios/iavl/#Datos_abiertos

#Estos se encuentran descargados previamente en nuestro directorio de trabajo
#setwd("C:/Users/Carolina/Desktop/H�bridos 2016-2020/Datos")

#Cargamos las librerias necesarias 
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(plyr)))
suppressWarnings(suppressMessages(library(ggplot2)))
suppressWarnings(suppressMessages(library(tidyr)))
suppressWarnings(suppressMessages(library(forecast)))

#Leemos los archivos del directorio para importarlos a R.
h_2016 <- read.csv("hibrido_2016.csv")
h_2017 <- read.csv("hibrido_2017.csv")
h_2018 <- read.csv("hibrido_2018.csv")
h_2019 <- read.csv("hibrido_2019.csv")
h_2020 <- read.csv("hibrido_2020.csv")

names(h_2016);names(h_2017);names(h_2018);names(h_2019);names(h_2020)
str(h_2016) #Conocemos la estructura de nuestra base de datos 

#Con ello nos damos cuenta que las columnas $ ..PROD_EST y  $ COBERTURA no son �tiles

#Es conveniente tener todos los archivos en un �nico archivo 
hlist <- list(h_2016,h_2017,h_2018,h_2019,h_2020)
util  <- lapply(hlist, select, ANIO:VEH_HIBRIDAS)

data_h <- do.call(rbind, util) #Combinando en un �nico dataframe

#Es necesario cargar los archivos adicional correspondiente a ID_ENTIDAD
entidad <- read.csv("entidad_federativa.csv")

#De tal forma que podemos unir ambas bases de datos para que quere en una sola
datos_hibrid <- merge(x=data_h, y=entidad, by="ID_ENTIDAD")

datos_hibrid <- arrange(datos_hibrid,ANIO,ID_MES) #Primero ordenamos por a�o y mes


names(datos_hibrid) #nombre de las columnas y el orden de aparici�n
datos_hibrid <- datos_hibrid[, c(2,3,1,7,4,5,6)] #nuevo orden de las columnas
head(datos_hibrid)

#Lo guardamos en una base de datos para tenerlo disponible
#hibrid_vehicle <- write.csv()

#Venta veh�culos a nivel nacional. Es �til arreglar la fecha
fecha_hibrid <- datos_hibrid %>% unite("FECHA",ANIO:ID_MES,sep="-",remove = F,na.rm=T)
fecha_hibrid <- fecha_hibrid[,c(1,5,6,7,8)] #ordenando las columnas
d <- rep(1,dim(fecha_hibrid)[1]) #Para poder transformar a formato de fecha, un truco es argregar una columna num�rica y unirla
fecha_hibrid <- cbind(fecha_hibrid,d)
fecha_hibrid <- fecha_hibrid[,c(1,6,2,3,4,5)]
fecha_hibrid <- fecha_hibrid %>% unite("FECHA_COMP",FECHA:d,sep="-",remove = F,na.rm=T) #creando la fecha completa 
fecha_hibrid <- fecha_hibrid[,c(1,4,5,6,7)]

fecha_hibrid <- mutate(fecha_hibrid,FECHA_COMP = as.Date(FECHA_COMP,"%Y-%m-%d")) #cambiando el formato
fecha_hibrid <- mutate(fecha_hibrid, fecha= format.Date(FECHA_COMP,"%Y-%m")) # dejando la fecha real
fecha_hibrid <- fecha_hibrid[,c(6,2,3,4,5)]


#........... An�lisis gr�fico ...............

#### SERIES DE TIEMPO DEL PERIODO ENE 2016- OCT 2020

#Promedios de Venta nacional de veh�culos el�ctricos
elec_nac <- ddply(fecha_hibrid, .(fecha) ,summarise, ELEC_PROM= mean(VEH_ELECTR))
ts.h <- ts(elec_nac$ELEC_PROM,st=2016,fr=12)
ts.plot(ts.h, gpars=list(xlab="A�o",ylab="Promedio de ventas", main= "Promedio de anual ventas de veh�culos el�ctricos"), 
        type= "o",col = "red")

#Promedios de Venta nacional de veh�culos h�bridos plug-in
hp_nac <- ddply(fecha_hibrid, .(fecha) ,summarise, PLUGIN_PROM= mean(VEH_HIBRIDAS_PLUGIN))
ts.plugin <- ts(hp_nac$PLUGIN_PROM,st=2016,fr=12)
ts.plot(ts.plugin,  gpars=list(xlab="A�o", ylab="Promedio de ventas", main= "Promedio anual de ventas de veh�culos h�bridos PLUG-IN"), 
        type= "o",col = "blue")

#Promedios de Venta nacional de veh�culos h�bridos
hib_nac <- ddply(fecha_hibrid, .(fecha) ,summarise, HIB_PROM= mean(VEH_HIBRIDAS))
ts.hibrid <- ts(hib_nac$HIB_PROM,st=2016,fr=12)
ts.plot(ts.hibrid,gpars=list(xlab="A�o", ylab="Promedio de ventas", main= "Promedio anual de ventas de veh�culos h�bridos"), 
        type= "o",col = "forestgreen")

## Acumulado de ventas 

#electricos 
e <- ddply(fecha_hibrid, .(fecha) ,summarise, ELEC= sum(VEH_ELECTR)) 
ts.e <- ts(e$ELEC,st=2016,fr=12)

#plugin
pi <- ddply(fecha_hibrid, .(fecha) ,summarise, PLUGIN= sum(VEH_HIBRIDAS_PLUGIN))
ts.pi <- ts(pi$PLUGIN,st=2016,fr=12)

#hibridos
hi <- ddply(fecha_hibrid, .(fecha) ,summarise, HIBRID= sum(VEH_HIBRIDAS))
ts.hi <- ts(hi$HIBRID,st=2016,fr=12)


### An�lisis estad�stico de las series de tiempo, descomposici�n de las series ### 

#el�ctricos 
elec_desc <- decompose(ts.h)
## plot the obs ts, trend & seasonal effect (aditivo)
plot(elec_desc, xlab = "A�o")

#Plug-in
plug_desc <- decompose(ts.plugin)
## plot the obs ts, trend & seasonal effect (aditivo)
plot(plug_desc,xlab = "A�o")

#H�bridos

hib_desc <- decompose(ts.hibrid)
## plot the obs ts, trend & seasonal effect (aditivo)
plot(hib_desc,xlab = "A�o")

########

## An�lisis de datos en ventas 

layout(1:3) #con aggregate observamos la tendencia de ventas
plot(aggregate(ts.e), xlab = "A�o", ylab="acumulado ventas", xaxt ="n",col="red",
     main = "Tendencia ventas totales de veh�culos el�ctricos", 
     sub = "M�xico en periodo 2016-2020")
axis(1,at=c(2016:2020))

plot(aggregate(ts.pi), xlab = "A�o", ylab="acumulado ventas",xaxt ="n", col="blue",
     main = "Tendencia ventas totales de veh�culos plug-in", 
     sub = "M�xico en periodo 2016-2020")
axis(1,at=c(2016:2020))

plot(aggregate(ts.e), xlab = "A�o", ylab="acumulado ventas",xaxt ="n", col ="forestgreen",
     main = "Tendencia ventas totales de veh�culos h�bridos", 
     sub = "M�xico en periodo 2016-2020")
axis(1,at=c(2016:2020))

dev.off()

## boxplots

boxplot(ts.e ~ cycle(ts.e), ylab = "ventas", col = "red",
        xlab = "Boxplot de valores estacionales",
        main = "Ventas totales de veh�culos el�ctricos",
        sub= "M�xico en periodo 2016-2020")

boxplot(ts.pi ~ cycle(ts.pi), ylab = "ventas", col = "blue",
        xlab = "Boxplot de valores estacionales",
        main = "Ventas totales de veh�culos h�bridos plug-in",
        sub = "M�xico en periodo 2016-2020")

boxplot(ts.hi ~ cycle(ts.hi), ylab = "ventas", col = "forestgreen",
        xlab = "Boxplot de valores estacionales",
        main = "Ventas totales de veh�culos h�bridos",
        sub = "M�xico en periodo 2016-2020")

#### Gr�ficos de barras de promedio ventas de veh�culos por entidad federativa #####


#Por entidad federativa promedio ventas de autom�viles el�ctricos 
ele_ent <- ddply(fecha_hibrid, .(DESC_ENTIDAD) ,summarise, ELEC_PROM= mean(VEH_ELECTR))


electric <- ggplot(ele_ent, aes(x = DESC_ENTIDAD, y = ELEC_PROM)) + 
  geom_bar (stat="identity", color="black", fill="red") +
  ggtitle('Venta nacional de de veh�culos el�ctricos en Ene 2016 -Oct 2020')+
  xlab("Entidades federativas")+
  ylab("Promedio de ventas")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, hjust = 0))

electric

#Por entidad federativa promedio de las ventas de autom�viles h�bridos-plugin
plug_ent<-ddply(fecha_hibrid, .(DESC_ENTIDAD) ,summarise, PLUGIN_PROM= mean(VEH_HIBRIDAS_PLUGIN))

hibrid_plugin <- ggplot(plug_ent, aes(x = DESC_ENTIDAD, y = PLUGIN_PROM)) + 
  geom_bar (stat="identity", color="black", fill="blue") +
  ggtitle('Venta nacional de de veh�culos plugin-h�bridos en Ene 2016 - Oct 2020')+
  xlab("Entidades federativas")+
  ylab("Promedio de ventas")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, hjust = 0))

hibrid_plugin


#Por entidad federativa promedio de ventas de autom�viles h�bridos-plugin
hib_ent<- ddply(fecha_hibrid, .(DESC_ENTIDAD) ,summarise, HIB_PROM= mean(VEH_HIBRIDAS)) 

hibrid_graf <- ggplot(hib_ent, aes(x = DESC_ENTIDAD, y = HIB_PROM)) + 
  geom_bar (stat="identity", color="black", fill="forestgreen") +
  ggtitle('Venta nacional de de veh�culos h�bridos en Ene 2016 - Oct 2020 ')+
  xlab("Entidades federativas")+
  ylab("Promedio de ventas")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, hjust = 0))

hibrid_graf

#######
## Proyecciones a futuro : forecasting ## 
#Predicciones a 12 meses de ventas
autoarima_ele  <- auto.arima(ts.e)
autoarima_plug <- auto.arima(ts.pi)
autoarima_hib  <- auto.arima(ts.hi)

f_ele <- forecast(autoarima_ele,h=12)

plot(f_ele, main="Predicciones de ventas de veh�culos el�ctricos", xlab = "A�o",
     ylab="Acumulado de ventas",sub="Predicci�n basada en ARIMA a 12 meses")


#Analizando basados en los residuos
plot(f_ele$residuals) # observamos los residuales
qqnorm(f_ele$residuals) #gr�fico de cuartiles
acf(f_ele$residuals) #Grafico de correlacion de residuos
pacf(f_ele$residuals)

##### h�bridos plug in
f_pi <- forecast(autoarima_plug,h=12)

plot(f_pi, main="Predicciones de ventas de veh�culos h�bridos plug-in", xlab = "A�o",
     ylab="Acumulado de ventas",sub="Predicci�n basada en ARIMA a 12 meses")


#Analizando basados en los residuos
plot(f_pi$residuals) # observamos los residuales
qqnorm(f_pi$residuals) #gr�fico de cuartiles
acf(f_pi$residuals) #Grafico de correlacion de residuos
pacf(f_pi$residuals)

### h�bridos 

f_hib <- forecast(autoarima_hib,h=12)

plot(f_hib, main="Predicciones de ventas de veh�culos h�bridos", xlab = "A�o",
     ylab="Acumulado de ventas",sub="Predicci�n basada en ARIMA a 12 meses")


#Analizando el an�lisis arima basados en los residuos
plot(f_hib$residuals) # observamos los residuales
qqnorm(f_hib$residuals) #gr�fico de cuartiles
acf(f_hib$residuals) #Grafico de correlacion de residuos
pacf(f_hib$residuals)


## Este an�lisis realizado con forecast, al compararlo con las series de tiempo
# y las tendencias de ventas obtenidos anteriormente, parecen no ajustarse o 
#predecir de manera adecuada, por lo que se propone mejorar el modelo a futuro
