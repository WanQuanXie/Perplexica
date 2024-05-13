FROM node:alpine as builder

WORKDIR /home/perplexica

COPY ui /home/perplexica/

# Specific Next.js output for standalone
RUN echo "const nextConfig={output: 'standalone',images:{remotePatterns:[{hostname:'s2.googleusercontent.com'}]}};export default nextConfig;" > ./next.config.mjs

RUN yarn install
RUN yarn build

FROM node:alpine as runner

ARG NEXT_PUBLIC_WS_URL
ARG NEXT_PUBLIC_API_URL
ARG PORT

ENV NEXT_PUBLIC_WS_URL=${NEXT_PUBLIC_WS_URL}
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
ENV PORT=${PORT}

WORKDIR /home/perplexica

COPY --from=builder /home/perplexica/package.json .
COPY --from=builder /home/perplexica/yarn.lock .
COPY --from=builder /home/perplexica/next.config.mjs .
COPY --from=builder /home/perplexica/.next/standalone .
COPY --from=builder /home/perplexica/public ./public
COPY --from=builder /home/perplexica/.next/static ./.next/static

ENTRYPOINT ["node", "server.js"]