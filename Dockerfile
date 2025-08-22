# Etapa de build
FROM node:18 AS build

WORKDIR /usr/src/app

# Copia apenas arquivos de dependência primeiro (para melhor uso do cache)
COPY package.json package-lock.json ./

# Instala apenas dependências de produção
RUN npm ci --omit=dev && npm cache verify

# Copia o restante do código
COPY . .

# Compila a aplicação
RUN npm run build

# Etapa final (imagem leve para rodar)
FROM node:18-alpine3.19

WORKDIR /usr/src/app

# Copia apenas o necessário da etapa de build
COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules

EXPOSE 3000

CMD ["npm", "run", "start:prod"]
