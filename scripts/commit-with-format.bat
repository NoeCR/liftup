@echo off
echo 🔧 Formateando código Dart...
dart format .

echo 📝 Agregando archivos al staging area...
git add .

echo 💾 Haciendo commit...
git commit -m "%*" --no-verify

echo 🚀 Haciendo push...
git push origin mejora-gestion-progresiones

echo ✅ Commit y push completados!
