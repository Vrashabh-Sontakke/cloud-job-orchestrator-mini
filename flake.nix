{
  description = "dev environment for Go cloud orchestrator";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [

            #Go tools
            go                       
            gopls                     
            gotools                   
            gofumpt                   
            golangci-lint            
            air                       
            delve                     
            goreleaser                

            # Go testing & mocking 
            gotestsum                 
            mockgen                  

            # Database migrations 
            goose                                             

            #go vulnerablity scanning
            govulncheck               
                                     

            # protobuf, grpc 
            protobuf                  
            protoc-gen-go             
            protoc-gen-go-grpc       
            buf                       
            grpcurl                   
            evans                     

            # PostgreSQL 
            postgresql_16
            pgcli
            sqlfluff                  

            redis                     # redis-cli

            natscli                   # nats cli — pub/subscribe/stream testing

            awscli2                   # AWS CLI v2

            #Docker
            docker-compose
            dockerfile-language-server
            lazydocker
            dive                      
            hadolint                  

            # kubernetes
            kubectl
            kubectx                   
            k9s                       
            kind                      
            helm

            openssl
            curl
            jq
            yq                        
            yaml-language-server
            gnumake
            ripgrep
            lazygit

            # htmx, templ, tailwindcss (node package)
            templ
            htmx-lsp
            tailwindcss_4
          ];

          shellHook = ''
            echo ""
            echo "  Cloud Orchestrator dev environment"
            echo "  Go:          $(go version)"
            echo "  protoc:      $(protoc --version)"
            echo "  buf:         $(buf --version)"
            echo "  kubectl:     $(kubectl version --client 2>/dev/null | head -1)"
            echo "  psql:        $(psql --version)"
            echo ""
            echo "  Key commands:"
            echo "    gotestsum ./...                    run all tests"
            echo "    govulncheck ./...                  scan vulnerabilities"
            echo "    goose -dir db/migrations postgres \$DATABASE_URL up"
            echo "    mockgen -source=internal/ports/interfaces.go"
            echo "    buf generate                       regenerate proto"
            echo "    evans --proto proto/worker.proto repl"
            echo "    docker compose up -d               start all services"
            echo ""
          '';

          GOROOT = "${pkgs.go}/share/go";
        };
      });
    };
}
