# $ docker build -t <USER_NAME>/app-2.05 .
# $ AGE_VERSION=$(curl -s "https://api.github.com/repos/FiloSottile/age/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
# $ sudo apt-get install age
# $ age-keygen -o key.txt
# $ go get -u go.mozilla.org/sops/cmd/sops
# $ sops --encrypt --age age1yqdy6ymr0f4aacrq5ehamcp2ua8amj26cjeyrzu9s2k7g9cgz43snaafyy --encrypted-regex '^(data)$' secret.yaml > secret.enc.yaml
# $ export SOPS_AGE_KEY_FILE=$(pwd)/key.txt
# $ sops --decrypt secret.enc.yaml > tmp.yaml
# $ kubectl apply -f manifests/deployment.yaml -f manifests/ingress.yaml -f manifests/service.yaml -f manifests/secret.enc.yaml
# $ kubectl describe pod <POD_NAME>
# http://localhost:8081

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

CMD ["npm", "start"]