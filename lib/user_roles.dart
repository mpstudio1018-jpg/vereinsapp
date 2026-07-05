/// 1. Definition aller verfügbaren Rollen im Verein
enum UserRole {
  vereinsAdmin,
  trainer,
  coTrainer,
  betreuer,
  spieler,
  eltern
}

/// 2. Datenstruktur für ein Mitglied / Benutzer
class AppUser {
  final String name;
  final UserRole role;
  final String team; // z.B. "C-Jugend"

  AppUser({
    required this.name,
    required this.role,
    required this.team,
  });

  /// Gibt die Rolle als lesbaren Text für die App zurück
  String get roleName {
    switch (role) {
      case UserRole.vereinsAdmin:
        return 'Vereins-Administrator';
      case UserRole.trainer:
        return 'Cheftrainer';
      case UserRole.coTrainer:
        return 'Co-Trainer';
      case UserRole.betreuer:
        return 'Betreuer / Orga';
      case UserRole.spieler:
        return 'Spieler';
      case UserRole.eltern:
        return 'Elternteil';
    }
  }
}

/// 3. Das Rechte-System (Die Berechtigungs-Prüfungen)
class Permissions {
  
  /// BERECHTIGUNGEN AUF VEREINS-EBENE (Klick auf Vereinswappen)
  
  // Nur der Vereins-Admin darf das Haupt-Wappen des Vereins austauschen
  static bool darfVereinsWappenAendern(AppUser user) {
    return user.role == UserRole.vereinsAdmin;
  }

  // Nur Admins und Trainer dürfen offizielle Vereins-News für alle posten
  static bool darfVereinsNewsPosten(AppUser user) {
    return user.role == UserRole.vereinsAdmin || user.role == UserRole.trainer;
  }


  /// BERECHTIGUNGEN AUF TEAM-EBENE (Klick auf Mannschaftsfoto)
  
  // Trainer, Co-Trainer und Betreuer dürfen das Mannschaftsfoto der C-Jugend ändern
  static bool darfMannschaftsfotoAendern(AppUser user) {
    return user.role == UserRole.trainer ||
           user.role == UserRole.coTrainer ||
           user.role == UserRole.betreuer ||
           user.role == UserRole.vereinsAdmin;
  }

  // Wer darf die Teamkasse bearbeiten (Strafen eintragen, Beiträge abbuchen)?
  // Spieler und Eltern dürfen sie später nur SEHEN, aber nicht bearbeiten.
  static bool darfTeamkasseBearbeiten(AppUser user) {
    return user.role == UserRole.trainer || 
           user.role == UserRole.betreuer || 
           user.role == UserRole.vereinsAdmin;
  }

  // Wer darf neue Spieler manuell in die C-Jugend einpflegen?
  static bool darfSpielerEinpflegen(AppUser user) {
    return user.role == UserRole.trainer || 
           user.role == UserRole.betreuer || 
           user.role == UserRole.vereinsAdmin;
  }
}
