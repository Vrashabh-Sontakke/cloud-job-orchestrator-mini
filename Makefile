# run templ generation in watch mode to detect all .templ files and
# re-create _templ.txt files on change, then send reload event to browser.
# Default url: http://localhost:7331
live/templ:
	templ generate --watch --proxy="http://localhost:8080" --open-browser=false -v

# run air to detect any go file changes to re-build and re-run the server.
live/server:
	go run github.com/air-verse/air@v1.62.0 \
	--build.cmd "go build -o tmp/bin/main" --build.bin "tmp/bin/main" --build.delay "100" \
	--build.exclude_dir "node_modules" \
	--build.include_ext "go" \
	--build.stop_on_error "false" \
	--misc.clean_on_exit true

# run tailwindcss to generate the styles.css bundle in watch mode.
live/tailwind:
	tailwindcss -i ./assets/css/input.css -o ./assets/output.css
#    npx @tailwindcss/cli -i ./assets/css/input.css -o ./assets/output.css --watch=always

# live/postcss:
# 	npx postcss ./assets/css/input.css -o ./assets/output.css -w
# run esbuild to generate the index.js bundle in watch mode.
# live/esbuild:
# 	npx esbuild js/index.ts --bundle --outdir=assets/ --watch

# watch for any js or css change in the assets/ folder, then reload the browser via templ proxy.
live/sync_assets:
	go run github.com/cosmtrek/air@v1.51.0 \
	--build.cmd "templ generate --notify-proxy" \
	--build.bin "true" \
	--build.delay "100" \
	--build.exclude_dir "" \
	--build.include_dir "assets" \
	--build.include_ext "js,css"

# start all 4 watch processes in parallel.
# start all 4 watch processes in parallel.
live:
	make -j4 live/templ live/server live/tailwind live/sync_assets

clean:
	./cleanup.sh

pocketbase:
	go run ./cmd/pocketbase_entrypoint/main.go


# ===================== Build ===================== #
# ================== (Production) ================= #


# Generate templ files for production
build/templ:
	templ generate -v

# Build the Go server for production
build/server:
	go build -o main .

# Generate the styles.css bundle for production
build/tailwind:
	npx @tailwindcss/cli -i ./assets/css/input.css -o ./assets/output.css --minify

# build/postcss:
# 	npx postcss -i ./assets/css/input.css -o ./assets/output2.css

# Generate the index.js bundle for production
# build/esbuild:
# 	npx esbuild js/index.ts --bundle --outdir=assets/ --minify

# Run all build processes sequentially for production
build: build/templ build/server build/tailwind

