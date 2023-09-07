# base stage
FROM node:20-alpine AS base
WORKDIR /usr/src/app
RUN npm i -g pnpm

# dependencies stage
FROM base AS dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# development stage
FROM base AS development
COPY --from=dependencies /usr/src/app/node_modules ./node_modules

# build stage
FROM base AS build
ENV NODE_ENV production
COPY . .
COPY --from=dependencies /usr/src/app/node_modules ./node_modules
RUN pnpm build
RUN pnpm prune --prod

# production stage
FROM base AS production
ENV NODE_ENV production
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
CMD [ "node", "dist/main.js" ]

