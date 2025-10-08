@echo off
echo 📝 Agregando archivos al staging area...
git add .

echo 💾 Haciendo commit...
git commit -m "%*"

echo 🚀 Haciendo push...
git push origin mejora-gestion-progresiones

echo ✅ Commit y push completados!
