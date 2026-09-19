FROM nginx:alpine
# Eliminar archivos estáticos por defecto de nginx
RUN rm -rf /usr/share/nginx/html/* 
# Copiar los archivos de tu app a la carpeta html de nginx
COPY ./app/ /usr/share/nginx/html
# Exponer el puerto 80
EXPOSE 80
# Iniciar servidor nginx
CMD ["nginx", "-g", "daemon off;"]



