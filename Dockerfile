# Stage 1: Build React Admin
FROM node:18 AS react-build
WORKDIR /app
COPY admin_dashboard/package*.json ./admin_dashboard/
RUN npm ci --prefix admin_dashboard
COPY admin_dashboard/ ./admin_dashboard/
RUN npm run build --prefix admin_dashboard

# Stage 2: Build Flutter web
FROM cirrusci/flutter:stable AS flutter-build
WORKDIR /app
COPY teacher_app/pubspec.* ./teacher_app/
RUN flutter pub get --directory=teacher_app
COPY teacher_app/ ./teacher_app/
RUN flutter build web --release --directory=teacher_app

# Stage 3: Serve both with nginx
FROM nginx:alpine
# Copy React build
COPY --from=react-build /app/admin_dashboard/build /usr/share/nginx/html/admin
# Copy Flutter build
COPY --from=flutter-build /app/teacher_app/build/web /usr/share/nginx/html/teacher
# nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf
