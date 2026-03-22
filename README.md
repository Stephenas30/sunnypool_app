# 🌞 Sunny — Assistant intelligent pour piscines

## 📖 Cahier des charges
Le cahier des charges complet est disponible ici :  
[Consulter le document](https://docs.google.com/document/d/1K2HP9SdpENsld6CK0uX_suZPF8zEXekpvADgKQ1OzCo/edit?tab=t.0)

---

## 🎯 Objectif du projet
Sunny est une application **mobile + web** conçue pour aider les propriétaires de piscines à :
- Enregistrer leur bassin et ses équipements  
- Suivre les produits utilisés  
- Saisir ou analyser les tests d’eau (manuels ou via photo)  
- Obtenir des recommandations précises grâce à l’IA Sunny  
- Dialoguer avec Sunny et archiver les conversations  
- Recevoir des rappels d’entretien et alertes météo  

Le MVP doit être **simple mais robuste**, afin de valider l’usage réel.

---

## 🛠️ Stack technique recommandée
- **Frontend** : Flutter (mobile + web) ou React Native + React Web  
- **Backend** : Node.js / NestJS ou Laravel  
- **Base de données** : PostgreSQL  
- **Stockage images** : AWS S3 ou Cloudflare R2  
- **IA** : OpenAI API (GPT + Vision)  
- **API météo** : OpenWeatherMap ou MeteoAPI  
- **Notifications** : Firebase Cloud Messaging  

---

## 📦 Modules fonctionnels du MVP
1. Gestion des comptes utilisateurs  
2. Fiche piscine (type, dimensions, hydraulique, filtration, traitement, équipements, photos)  
3. Produits utilisés (catégories, photos, analyse IA)  
4. Analyse de l’eau (saisie manuelle ou photo bandelette)  
5. Historique des analyses  
6. Assistant IA Sunny (chat intégré)  
7. Archivage des conversations  
8. Diagnostic photo piscine (eau verte, trouble, algues…)  
9. Calcul de dosage personnalisé  
10. Planning d’entretien (hebdomadaire/mensuel)  
11. Alertes météo (canicule, gel, orage)  
12. Tutoriels (hivernage, remise en route, traitement eau verte…)  

---

## 🔐 Sécurité
- Authentification JWT  
- Stockage sécurisé des images  
- Validation stricte des données utilisateur  

---

## 📅 Planning de développement
- **Durée estimée** : 6 à 8 semaines  
- **Livrables** :  
  - Application mobile (iOS + Android)  
  - Application web  
  - Backend opérationnel  
  - Base de données PostgreSQL  
  - Assistant IA Sunny fonctionnel  

---

## 🚀 Étapes suivantes
- Réalisation des **maquettes UX** écran par écran (22 écrans prévus)  
- Optimisation de l’expérience utilisateur avant le développement  

---