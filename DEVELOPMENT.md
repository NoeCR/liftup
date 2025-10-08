# Guía de Desarrollo

## Formateo Automático de Código

Para evitar problemas con el formateo de código durante los commits, hemos configurado varias opciones:

### Opción 1: Usar el alias de Git (Recomendado)
```bash
git commit-format "tu mensaje de commit"
```
Este comando:
1. Formatea todo el código con `dart format .`
2. Agrega los archivos formateados al staging area
3. Hace el commit con tu mensaje

### Opción 2: Usar el script de Windows (Recomendado para Windows)
```cmd
.\scripts\commit.bat "tu mensaje de commit"
```

### Opción 3: Usar el script de PowerShell
```powershell
.\scripts\commit.ps1 "tu mensaje de commit"
```

### Opción 4: Formateo manual antes del commit
```bash
dart format .
git add .
git commit -m "tu mensaje"
git push origin mejora-gestion-progresiones
```

### Opción 5: Configuración del Editor (VS Code)
El archivo `.vscode/settings.json` está configurado para formatear automáticamente al guardar.

## Pre-commit Hook
También hay un pre-commit hook configurado que formatea automáticamente el código antes de cada commit.

## Recomendación
- **Para Windows**: Usa `.\scripts\commit.bat "mensaje"` para commits rápidos y consistentes
- **Para otros sistemas**: Usa `git commit-format "mensaje"` o configura tu editor para formatear automáticamente al guardar
