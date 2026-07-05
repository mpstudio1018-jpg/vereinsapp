import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cards_table.dart';
import 'models/fussball_de_match_dto.dart';
import 'services/fussball_de_import_repository.dart';
import 'widgets/vereins_news_overview.dart';
import 'tabelle_screen.dart';

// Farb- und Stil-Konstanten zur zentralen Pflege
const Color kPrimaryColor = Color(0xFF800020);
const Color kSecondaryColor = Color(0xFF941834);
const Color kBackgroundColor = Color(0xFF0F172A);
const Color kCardColor = Color(0xFF131926);
const Color kDarkBackground = Color(0xFF0B0F19);
const Color kBorderColor = Color(0xFF334155);
const Color kAccentTrack = Color(0xFF8A2C2C);
const int kMaxPreparationWeeks = 12;

double adaptiveDialogWidth(BuildContext context, {double desktopWidth = 560}) {
  final screenWidth = MediaQuery.of(context).size.width;
  return screenWidth > 700 ? desktopWidth : screenWidth * 0.92;
}

class AppI18n {
  final Locale locale;

  AppI18n(this.locale);

  static AppI18n of(BuildContext context) {
    return Localizations.of<AppI18n>(context, AppI18n)!;
  }

  static const supportedLocales = [Locale('de'), Locale('en'), Locale('tr')];

  static const Map<String, Map<String, String>> _localized = {
    'de': {
      'app_title': 'Vereins App',
      'nav_home': 'Dashboard',
      'nav_communication': 'Kommunikation',
      'nav_team': 'Team',
      'nav_schedule': 'Termin',
      'nav_profile': 'Profil',
      'language': 'Sprache',
      'language_de': 'Deutsch',
      'language_en': 'Englisch',
      'language_tr': 'Türkisch',
      'channels_chats': 'Kanäle & Chats',
      'private_chats': 'PRIVATCHATS',
      'new_private_chat': 'Neuen Privatchat starten',
      'search_member': 'Mitglied suchen...',
      'person_add': 'Mitglieder einpflegen',
      'create_termin': 'Termin / Serie anlegen',
      'overview_schedule': 'Terminübersicht',
      'filter_schedule':
          'Filtere Termine nach Kategorie und sieh dir an, wer zugesagt hat.',
      'all': 'Alle',
      'training': 'Training',
      'game': 'Spiel',
      'other': 'Sonstiges',
      'club_org': 'Vereins-Organisation',
      'club_org_desc': 'Verwalte News, Mitglieder und Beschwerden.',
      'club_news': 'News (Verein)',
      'club_news_desc': 'Aktuelle Ankuendigungen und Vereinsinfos.',
      'club_members': 'Vorstand / Funktionaere',
      'club_members_desc':
          'Der offizielle Vorstand und Ansprechpartner des Hauptvereins.',
      'club_feedback': 'Feedback & Beschwerden',
      'club_feedback_desc': 'Eingereichte Rueckmeldungen und Status.',
      'news_infos': 'News & Vereinsinfos',
      'news_infos_desc': 'Die wichtigsten Meldungen aus dem Vereinsleben.',
      'members_officials': 'Vorstand & Funktionaere',
      'members_officials_desc':
          'Der offizielle Vorstand und Ansprechpartner des TV Friedrichstein.',
      'feedback_manage_desc':
          'Verwalte Rueckmeldungen aus Kader und Elternbereich.',
      'new_feedback_create': 'Neues Feedback erstellen',
      'mark_done': 'Als erledigt markieren',
      'new_feedback_capture': 'Neues Feedback erfassen',
      'title_label': 'Titel',
      'description_label': 'Beschreibung',
      'cancel': 'Abbrechen',
      'save': 'Speichern',
      'communication': 'Kommunikation',
      'communication_desc': 'Interner Austausch fuer die C-Jugend',
      'team_chat': 'Team-Chat',
      'team_chat_desc':
          'Klicke hier, um die aktiven Kanaele oder Privatchats zu oeffnen und direkt zu schreiben.',
      'notes': 'Anmerkungen',
      'notes_desc':
          'Kategorisierte Meldungen (Anonym-Option). Nur fuer Trainer & Co-Trainer einsehbar.',
      'votes': 'Abstimmungen',
      'votes_desc':
          'Aktive Votings einsehen und abstimmen. Erstellung nur durch Trainerteam.',
      'no_private_chats': 'Noch keine Privatchats vorhanden.',
      'no_messages_chat':
          'Keine Nachrichten in diesem Chat. Schreibe die erste!',
      'message_to': 'Nachricht an {name}...',
      'no_member_found': 'Kein Mitglied gefunden.',
      'private_chat_exists': 'Privatchat bereits vorhanden',
      'create_private_chat': 'Neuen Privatchat erstellen',
      'notes_box': 'Anmerkungs-Box',
      'submit_note': 'Meldung / Anmerkung einreichen',
      'note_access_denied':
          'Nur das Trainer- und Co-Trainer-Team hat Zugriff auf die internen Anmerkungen.',
      'submit_note_title': 'Anmerkung einreichen',
      'note_hint': 'Deine Nachricht an die Trainer...',
      'submit_anonymous': 'Anonym einreichen',
      'send': 'Senden',
      'new_vote_start': 'Neue Umfrage starten',
      'open_status': 'OFFEN',
      'voted_status': 'ABGESTIMMT',
      'target_group': 'Zielgruppe',
      'create_vote': 'Umfrage erstellen',
      'question_title': 'Frage / Titel',
      'option_1': 'Option 1',
      'option_2': 'Option 2',
      'create': 'Erstellen',
      'team_cash': 'Teamkasse',
      'players_overview': 'Spieler-Uebersicht',
      'cash_balance': 'Kassenguthaben',
      'my_open_fines': 'Meine offenen Strafen',
      'pending_fines': 'Ausstehende Strafen',
      'open_fines_of': 'Offene Strafzahlungen von {name}',
      'open_sins_list': 'Offene Suendenliste des Kaders',
      'no_open_fines': 'Keine offenen Strafen vorhanden.',
      'mark_paid': 'Als bezahlt markieren',
      'open': 'Offen',
      'recent_transactions': 'Letzte Transaktionen',
      'fines_per_player': 'Strafen je Spieler',
      'total_open': 'Gesamt offen: {value} €',
      'total_paid': 'Gesamt bezahlt: {value} €',
      'no_fines_yet': 'Noch keine Strafen vorhanden.',
      'open_amount': 'Offen: {value} €',
      'paid_amount': 'Bezahlt: {value} €',
      'total_amount': 'Gesamt: {value} €',
      'close': 'Schliessen',
      'fine_catalog_empty':
          'Der Strafenkatalog ist leer. Bitte erst eine Regel anlegen.',
      'assign_fine': 'Strafe zuweisen',
      'step_1_player': '1. Spieler auswaehlen:',
      'step_2_offense': '2. Vergehen aus Katalog waehlen:',
      'step_3_payment': '3. Zahlungsstatus:',
      'already_paid': 'Bereits bezahlt',
      'book_fine': 'Strafe buchen',
      'fine_recorded_for': 'Strafe fuer {name} erfolgreich eingetragen!',
      'fine_catalog': 'Strafenkatalog',
      'delete_rule': 'Regel loeschen',
      'catalog_admin_only':
          'Nur Vereins-Admins duerfen den Katalog bearbeiten.',
      'add_new_rule': 'Neue Regel hinzufuegen',
      'rule_description': 'Regelbeschreibung',
      'fine_amount_label': 'Strafe (z.B. 5,00)',
      'add': 'Hinzufuegen',
      'profile_title': 'Profil',
      'own_account': 'Eigener Account',
      'role_label': 'Rolle: {role}',
      'open_team_cash': 'Offene Teamkasse',
      'next_7_days': 'Naechste 7 Tage',
      'appointments_count': '{count} Termine',
      'open_votes': 'Offene Abstimmungen',
      'month': 'Monat',
      'events_on_date': 'Termine am {date}',
      'clear_filter': 'Filter loeschen',
      'no_events_selected_day': 'Keine Termine am ausgewaehlten Tag.',
      'no_upcoming_in_category':
          'Keine bevorstehenden Termine in dieser Kategorie.',
      'past_events': 'Vergangene Termine',
      'delete_event': 'Termin loeschen',
      'confirm_delete_event': 'Moechtest du diesen Termin wirklich loeschen?',
      'deleted': 'Geloescht',
      'event_deleted': 'Termin geloescht',
      'event_created': 'Termin erstellt',
      'event_updated': 'Termin aktualisiert',
      'series_created_count': '{count} Serientermine erstellt',
      'justify_status': '{status} begruenden',
      'coach_requires_reason':
          'Dein Trainer verlangt eine Begruendung fuer diesen Status:',
      'reason_hint': 'z.B. Krank, Verletzung, Schule...',
      'min_5_chars': 'Mindestens 5 Buchstaben erforderlich.',
      'edit_team_photo': 'Mannschaftsbild bearbeiten',
      'choose_photo': 'Foto waehlen',
      'remove_photo': 'Foto entfernen',
      'choose_bg_color': 'Oder waehle eine Hintergrundfarbe:',
      'image_caption': 'Bildunterschrift',
      'crest_admin_only':
          'Nur der Vereins-Admin darf das Vereinswappen aendern.',
      'edit_crest': 'Vereinswappen bearbeiten',
      'choose_image': 'Bild waehlen',
      'remove_image': 'Bild entfernen',
      'choose_crest_color': 'Oder Wappenfarbe waehlen:',
      'import_members': 'Mitglieder einpflegen',
      'import_excel_csv': 'Excel / CSV Liste importieren',
      'enter_players_manually': 'Spieler manuell eintippen',
      'squad_availability': 'Kader-Verfuegbarkeit',
      'no_feedback_yet': 'Noch keine Rueckmeldungen vorhanden.',
      'registered_count': 'ANGEMELDET ({count})',
      'uncertain_count': 'UNSICHER ({count})',
      'canceled_count': 'ABGEMELDET ({count})',
      'no_confirmations': 'Keine Zusagen',
      'no_uncertain_feedback': 'Keine unsicheren Rueckmeldungen',
      'no_cancellations': 'Keine Absagen',
      'edit_event_form': 'Termin bearbeiten',
      'new_event_form': 'Neuen Termin erstellen',
      'event_name_required': 'Event-Name *',
      'date_required': 'Datum (TT.MM) *',
      'start_time_required': 'Startzeit (HH:MM) *',
      'meeting_time_optional': 'Treffzeit (optional)',
      'end_time_optional': 'Endzeit (optional)',
      'sports_facility_required': 'Sportanlage / Adresse *',
      'note_label': 'Notiz',
      'series_event_label': 'Als Serientermin anlegen',
      'duration_weeks': 'Dauer (Wochen): {weeks}',
      'nominate_roles': 'Rollen nominieren',
      'email_notify': 'E-Mail an nominierte Spieler versenden',
      'push_notify': 'Push-Nachricht an nominierte Spieler versenden',
      'reason_required_cancel': 'Grund-Pflicht bei Absage:',
      'fill_required_correctly': 'Bitte fuelle alle Pflichtfelder korrekt aus.',
      'end_must_be_after_start': 'Endzeit muss nach der Startzeit liegen.',
      'open_calendar': 'Kalender oeffnen',
      'select_time': 'Uhrzeit auswaehlen',
      'select_meeting_time': 'Treffzeit auswaehlen',
      'select_end_time': 'Endzeit auswaehlen',
      'welcome_back': 'Willkommen zurueck!',
      'u15_dashboard': 'C-Jugend Dashboard',
      'my_role': 'Meine Rolle:',
      'open_vote_banner_title': 'Offene Abstimmung',
      'open_vote_banner_text': 'Es gibt {count} offene Abstimmung(en).',
      'open_amount_banner_title': 'Offener Betrag',
      'open_amount_banner_text': 'Du hast {amount} € offen.',
      'next_events': 'Naechste Termine',
      'show_all': 'Alle anzeigen',
      'no_events_next_7_days': 'Keine Termine in den naechsten 7 Tagen.',
      'live_table_title': 'Live-Tabelle (Fussball.de API)',
      'back_to_overview': 'Zurueck zur Uebersicht',
      'team_center': 'Mannschaftszentrale',
      'squad_admin_finance': 'Kader-Verwaltung & Finanzen',
      'cash_status': 'Kassenstand',
      'rules': 'Regeln',
      'entries_count': '{count} Eintraege',
      'top_scorer': 'Top-Scorer',
      'cards': 'Karten',
      'yellow_red_cards': '{yellow} Gelb / {red} Rot',
      'team_cash_desc':
          'Uebersicht ueber Strafgelder, Guthaben und alle Ein-/Ausgaben.',
      'rules_catalog_title': 'Regeln (Strafenkatalog)',
      'rules_catalog_desc':
          'Der verbindliche Verhaltenskodex fuer Puenktlichkeit und Fairplay.',
      'statistics': 'Statistik',
      'statistics_desc':
          'Auswertungen zu Trainingsbeteiligung, Toren und Vorlagen.',
      'cards_desc': 'Gelbe und rote Karten im Team verwalten.',
      'squad_statistics': 'Kader-Statistik',
      'best_assists': 'Beste Vorlagen',
      'avg_participation_short': 'Durchsn. Teilnahme',
      'individual_stats': 'Einzelstatistiken',
      'player': 'Spieler',
      'goals_short': 'T',
      'assists_short': 'V',
      'participation_short': 'Beteil.',
      'analysis': 'Analyse',
      'top_scorer_analysis': 'Top-Scorer: {name} mit {goals} Toren',
      'best_assists_analysis': 'Beste Vorlagen: {name} mit {assists} Assists',
      'avg_participation_analysis':
          'Durchschnittliche Trainingsbeteiligung: {value} %',
      'module_opened': 'Modul "{title}" geoeffnet.',
      'delete_appointment_tooltip': 'Termin loeschen',
      'view_participants_tooltip': 'Teilnehmer ansehen',
      'meeting_label': 'Treffen',
      'start_label': 'Beginn',
      'end_label': 'Ende',
      'place_label': 'Ort',
      'note_detail_label': 'Notiz',
      'not_specified': 'Nicht angegeben',
      'no_note_available': 'Keine Notiz vorhanden',
      'join_action': 'Anmelden',
      'unsure_action': 'Unsicher',
      'decline_action': 'Abmelden',
      'termin_select_title': 'Terminart waehlen',
      'termin_select_subtitle': 'Wie moechtest du den Termin erstellen?',
      'manual_create_section': 'Manuelle Erstellung',
      'fussball_import_title': 'FUSSBALL.DE Schnittstelle',
      'fussball_import_info':
          'Spielplan importieren: Importiere mit wenigen Klicks die Spiele deines Teams von FUSSBALL.DE.',
      'fussball_import_button': 'Von FUSSBALL.DE importieren',
      'fussball_import_done':
          'Verbindung zu FUSSBALL.DE wird hergestellt... Spielplan geladen.',
      'type_training': 'Training',
      'type_game': 'Spiel',
      'type_tournament': 'Turnier',
      'type_event': 'Event',
      'create_fullscreen_title': 'Termin erstellen',
      'fussball_import_loading': 'Import laeuft...',
      'fussball_import_failed':
          'Import von FUSSBALL.DE fehlgeschlagen. Bitte spaeter erneut versuchen.',
    },
    'en': {
      'app_title': 'Club App',
      'nav_home': 'Dashboard',
      'nav_communication': 'Communication',
      'nav_team': 'Team',
      'nav_schedule': 'Schedule',
      'nav_profile': 'Profile',
      'language': 'Language',
      'language_de': 'German',
      'language_en': 'English',
      'language_tr': 'Turkish',
      'channels_chats': 'Channels & Chats',
      'private_chats': 'PRIVATE CHATS',
      'new_private_chat': 'Start new private chat',
      'search_member': 'Search member...',
      'person_add': 'Add members',
      'create_termin': 'Create event / series',
      'overview_schedule': 'Schedule overview',
      'filter_schedule':
          'Filter appointments by category and see who has confirmed.',
      'all': 'All',
      'training': 'Training',
      'game': 'Game',
      'other': 'Other',
      'club_org': 'Club organization',
      'club_org_desc': 'Manage news, members and complaints.',
      'club_news': 'News (Club)',
      'club_news_desc': 'Current announcements and club info.',
      'club_members': 'Board / officials',
      'club_members_desc':
          'The official board and contacts of the parent club.',
      'club_feedback': 'Feedback & complaints',
      'club_feedback_desc': 'Submitted feedback and status.',
      'news_infos': 'News & club info',
      'news_infos_desc': 'The most important messages from club life.',
      'members_officials': 'Board & officials',
      'members_officials_desc':
          'The official board and contacts of TV Friedrichstein.',
      'feedback_manage_desc': 'Manage feedback from squad and parents.',
      'new_feedback_create': 'Create new feedback',
      'mark_done': 'Mark as done',
      'new_feedback_capture': 'Capture new feedback',
      'title_label': 'Title',
      'description_label': 'Description',
      'cancel': 'Cancel',
      'save': 'Save',
      'communication': 'Communication',
      'communication_desc': 'Internal communication for U15',
      'team_chat': 'Team chat',
      'team_chat_desc':
          'Open active channels or private chats and write directly.',
      'notes': 'Notes',
      'notes_desc':
          'Categorized reports (anonymous option). Visible to coaches only.',
      'votes': 'Polls',
      'votes_desc':
          'View active polls and vote. Creation only by coaching staff.',
      'no_private_chats': 'No private chats yet.',
      'no_messages_chat': 'No messages in this chat yet. Write the first one!',
      'message_to': 'Message to {name}...',
      'no_member_found': 'No member found.',
      'private_chat_exists': 'Private chat already exists',
      'create_private_chat': 'Create new private chat',
      'notes_box': 'Notes box',
      'submit_note': 'Submit report / note',
      'note_access_denied':
          'Only coaches and assistant coaches can access internal notes.',
      'submit_note_title': 'Submit note',
      'note_hint': 'Your message to the coaches...',
      'submit_anonymous': 'Submit anonymously',
      'send': 'Send',
      'new_vote_start': 'Start new poll',
      'open_status': 'OPEN',
      'voted_status': 'VOTED',
      'target_group': 'Target group',
      'create_vote': 'Create poll',
      'question_title': 'Question / title',
      'option_1': 'Option 1',
      'option_2': 'Option 2',
      'create': 'Create',
      'team_cash': 'Team cash',
      'players_overview': 'Players overview',
      'cash_balance': 'Cash balance',
      'my_open_fines': 'My open fines',
      'pending_fines': 'Pending fines',
      'open_fines_of': 'Open fines of {name}',
      'open_sins_list': 'Open squad fines list',
      'no_open_fines': 'No open fines.',
      'mark_paid': 'Mark as paid',
      'open': 'Open',
      'recent_transactions': 'Recent transactions',
      'fines_per_player': 'Fines per player',
      'total_open': 'Total open: {value} €',
      'total_paid': 'Total paid: {value} €',
      'no_fines_yet': 'No fines yet.',
      'open_amount': 'Open: {value} €',
      'paid_amount': 'Paid: {value} €',
      'total_amount': 'Total: {value} €',
      'close': 'Close',
      'fine_catalog_empty':
          'The fine catalog is empty. Please add a rule first.',
      'assign_fine': 'Assign fine',
      'step_1_player': '1. Select player:',
      'step_2_offense': '2. Select offense from catalog:',
      'step_3_payment': '3. Payment status:',
      'already_paid': 'Already paid',
      'book_fine': 'Book fine',
      'fine_recorded_for': 'Fine recorded successfully for {name}!',
      'fine_catalog': 'Fine catalog',
      'delete_rule': 'Delete rule',
      'catalog_admin_only': 'Only club admins may edit the catalog.',
      'add_new_rule': 'Add new rule',
      'rule_description': 'Rule description',
      'fine_amount_label': 'Fine (e.g. 5.00)',
      'add': 'Add',
      'profile_title': 'Profile',
      'own_account': 'Own account',
      'role_label': 'Role: {role}',
      'open_team_cash': 'Open team cash',
      'next_7_days': 'Next 7 days',
      'appointments_count': '{count} events',
      'open_votes': 'Open polls',
      'month': 'Month',
      'events_on_date': 'Events on {date}',
      'clear_filter': 'Clear filter',
      'no_events_selected_day': 'No events on selected day.',
      'no_upcoming_in_category': 'No upcoming events in this category.',
      'past_events': 'Past events',
      'delete_event': 'Delete event',
      'confirm_delete_event': 'Do you really want to delete this event?',
      'deleted': 'Deleted',
      'event_deleted': 'Event deleted',
      'event_created': 'Event created',
      'event_updated': 'Event updated',
      'series_created_count': '{count} series events created',
      'justify_status': 'Justify {status}',
      'coach_requires_reason': 'Your coach requires a reason for this status:',
      'reason_hint': 'e.g. sick, injury, school...',
      'min_5_chars': 'At least 5 characters required.',
      'edit_team_photo': 'Edit team photo',
      'choose_photo': 'Choose photo',
      'remove_photo': 'Remove photo',
      'choose_bg_color': 'Or choose a background color:',
      'image_caption': 'Image caption',
      'crest_admin_only': 'Only the club admin may change the crest.',
      'edit_crest': 'Edit club crest',
      'choose_image': 'Choose image',
      'remove_image': 'Remove image',
      'choose_crest_color': 'Or choose crest color:',
      'import_members': 'Import members',
      'import_excel_csv': 'Import Excel / CSV list',
      'enter_players_manually': 'Enter players manually',
      'squad_availability': 'Squad availability',
      'no_feedback_yet': 'No feedback yet.',
      'registered_count': 'REGISTERED ({count})',
      'uncertain_count': 'UNCERTAIN ({count})',
      'canceled_count': 'CANCELED ({count})',
      'no_confirmations': 'No confirmations',
      'no_uncertain_feedback': 'No uncertain responses',
      'no_cancellations': 'No cancellations',
      'edit_event_form': 'Edit event',
      'new_event_form': 'Create new event',
      'event_name_required': 'Event name *',
      'date_required': 'Date (DD.MM) *',
      'start_time_required': 'Start time (HH:MM) *',
      'meeting_time_optional': 'Meeting time (optional)',
      'end_time_optional': 'End time (optional)',
      'sports_facility_required': 'Sports facility / address *',
      'note_label': 'Note',
      'series_event_label': 'Create as recurring event',
      'duration_weeks': 'Duration (weeks): {weeks}',
      'nominate_roles': 'Nominate roles',
      'email_notify': 'Send email to nominated players',
      'push_notify': 'Send push notification to nominated players',
      'reason_required_cancel': 'Reason required on cancellation:',
      'fill_required_correctly': 'Please fill all required fields correctly.',
      'end_must_be_after_start': 'End time must be after start time.',
      'open_calendar': 'Open calendar',
      'select_time': 'Select time',
      'select_meeting_time': 'Select meeting time',
      'select_end_time': 'Select end time',
      'welcome_back': 'Welcome back!',
      'u15_dashboard': 'U15 Dashboard',
      'my_role': 'My role:',
      'open_vote_banner_title': 'Open poll',
      'open_vote_banner_text': 'There are {count} open poll(s).',
      'open_amount_banner_title': 'Open amount',
      'open_amount_banner_text': 'You have {amount} € outstanding.',
      'next_events': 'Upcoming events',
      'show_all': 'Show all',
      'no_events_next_7_days': 'No events in the next 7 days.',
      'live_table_title': 'Live table (Fussball.de API)',
      'back_to_overview': 'Back to overview',
      'team_center': 'Team center',
      'squad_admin_finance': 'Squad management & finance',
      'cash_status': 'Cash status',
      'rules': 'Rules',
      'entries_count': '{count} entries',
      'top_scorer': 'Top scorer',
      'cards': 'Cards',
      'yellow_red_cards': '{yellow} yellow / {red} red',
      'team_cash_desc': 'Overview of fines, balance and all income/expenses.',
      'rules_catalog_title': 'Rules (fine catalog)',
      'rules_catalog_desc':
          'Binding code of conduct for punctuality and fair play.',
      'statistics': 'Statistics',
      'statistics_desc': 'Insights on participation, goals and assists.',
      'cards_desc': 'Manage yellow and red cards in the team.',
      'squad_statistics': 'Squad statistics',
      'best_assists': 'Best assists',
      'avg_participation_short': 'Avg participation',
      'individual_stats': 'Individual stats',
      'player': 'Player',
      'goals_short': 'G',
      'assists_short': 'A',
      'participation_short': 'Part.',
      'analysis': 'Analysis',
      'top_scorer_analysis': 'Top scorer: {name} with {goals} goals',
      'best_assists_analysis': 'Best assists: {name} with {assists} assists',
      'avg_participation_analysis': 'Average training participation: {value} %',
      'module_opened': 'Module "{title}" opened.',
      'delete_appointment_tooltip': 'Delete appointment',
      'view_participants_tooltip': 'View participants',
      'meeting_label': 'Meeting',
      'start_label': 'Start',
      'end_label': 'End',
      'place_label': 'Place',
      'note_detail_label': 'Note',
      'not_specified': 'Not specified',
      'no_note_available': 'No note available',
      'join_action': 'Join',
      'unsure_action': 'Unsure',
      'decline_action': 'Decline',
      'termin_select_title': 'Choose event type',
      'termin_select_subtitle': 'How do you want to create the event?',
      'manual_create_section': 'Manual creation',
      'fussball_import_title': 'FUSSBALL.DE interface',
      'fussball_import_info':
          'Import schedule: Import your team matches from FUSSBALL.DE in just a few clicks.',
      'fussball_import_button': 'Import from FUSSBALL.DE',
      'fussball_import_done': 'Connecting to FUSSBALL.DE... Schedule loaded.',
      'type_training': 'Training',
      'type_game': 'Game',
      'type_tournament': 'Tournament',
      'type_event': 'Event',
      'create_fullscreen_title': 'Create event',
      'fussball_import_loading': 'Import in progress...',
      'fussball_import_failed':
          'FUSSBALL.DE import failed. Please try again later.',
    },
    'tr': {
      'app_title': 'Kulüp Uygulaması',
      'nav_home': 'Panel',
      'nav_communication': 'İletişim',
      'nav_team': 'Takım',
      'nav_schedule': 'Takvim',
      'nav_profile': 'Profil',
      'language': 'Dil',
      'language_de': 'Almanca',
      'language_en': 'İngilizce',
      'language_tr': 'Türkçe',
      'channels_chats': 'Kanallar ve Sohbetler',
      'private_chats': 'ÖZEL SOHBETLER',
      'new_private_chat': 'Yeni özel sohbet başlat',
      'search_member': 'Üye ara...',
      'person_add': 'Üye ekle',
      'create_termin': 'Etkinlik / seri oluştur',
      'overview_schedule': 'Takvim özeti',
      'filter_schedule':
          'Randevuları kategoriye göre filtreleyin ve katılımı görün.',
      'all': 'Tümü',
      'training': 'Antrenman',
      'game': 'Maç',
      'other': 'Diğer',
      'club_org': 'Kulup organizasyonu',
      'club_org_desc': 'Haberleri, uyeleri ve sikayetleri yonet.',
      'club_news': 'Haberler (Kulup)',
      'club_news_desc': 'Guncel duyurular ve kulup bilgileri.',
      'club_members': 'Yonetim / gorevliler',
      'club_members_desc': 'Ana kulubun resmi yonetimi ve iletisim kisileri.',
      'club_feedback': 'Geri bildirim ve sikayetler',
      'club_feedback_desc': 'Gonderilen geri bildirimler ve durumlari.',
      'news_infos': 'Haberler ve kulup bilgileri',
      'news_infos_desc': 'Kulup hayatindan en onemli duyurular.',
      'members_officials': 'Yonetim ve gorevliler',
      'members_officials_desc':
          'TV Friedrichstein resmi yonetimi ve iletisim kisileri.',
      'feedback_manage_desc':
          'Kadro ve velilerden gelen geri bildirimleri yonet.',
      'new_feedback_create': 'Yeni geri bildirim olustur',
      'mark_done': 'Tamamlandi olarak isaretle',
      'new_feedback_capture': 'Yeni geri bildirim kaydet',
      'title_label': 'Baslik',
      'description_label': 'Aciklama',
      'cancel': 'Iptal',
      'save': 'Kaydet',
      'communication': 'Iletisim',
      'communication_desc': 'U15 icin dahili iletisim',
      'team_chat': 'Takim sohbeti',
      'team_chat_desc':
          'Aktif kanallari veya ozel sohbetleri ac ve dogrudan yaz.',
      'notes': 'Notlar',
      'notes_desc':
          'Kategorili bildirimler (anonim secenekli). Sadece antrenorler gorebilir.',
      'votes': 'Oylamalar',
      'votes_desc':
          'Aktif oylamalari gor ve oy ver. Sadece teknik ekip olusturabilir.',
      'no_private_chats': 'Henuz ozel sohbet yok.',
      'no_messages_chat': 'Bu sohbette mesaj yok. Ilk mesaji sen yaz!',
      'message_to': '{name} kisine mesaj...',
      'no_member_found': 'Uye bulunamadi.',
      'private_chat_exists': 'Ozel sohbet zaten mevcut',
      'create_private_chat': 'Yeni ozel sohbet olustur',
      'notes_box': 'Not kutusu',
      'submit_note': 'Bildirim / not gonder',
      'note_access_denied':
          'Dahili notlara sadece antrenor ve yardimci antrenorler erisebilir.',
      'submit_note_title': 'Not gonder',
      'note_hint': 'Antrenorlere mesajin...',
      'submit_anonymous': 'Anonim gonder',
      'send': 'Gonder',
      'new_vote_start': 'Yeni anket baslat',
      'open_status': 'ACIK',
      'voted_status': 'OY VERILDI',
      'target_group': 'Hedef grup',
      'create_vote': 'Anket olustur',
      'question_title': 'Soru / baslik',
      'option_1': 'Secenek 1',
      'option_2': 'Secenek 2',
      'create': 'Olustur',
      'team_cash': 'Takim kasasi',
      'players_overview': 'Oyuncu gorunumu',
      'cash_balance': 'Kasa bakiyesi',
      'my_open_fines': 'Acik cezalarim',
      'pending_fines': 'Bekleyen cezalar',
      'open_fines_of': '{name} icin acik cezalar',
      'open_sins_list': 'Kadro acik ceza listesi',
      'no_open_fines': 'Acik ceza yok.',
      'mark_paid': 'Odendi olarak isaretle',
      'open': 'Acik',
      'recent_transactions': 'Son islemler',
      'fines_per_player': 'Oyuncu basina cezalar',
      'total_open': 'Toplam acik: {value} €',
      'total_paid': 'Toplam odendi: {value} €',
      'no_fines_yet': 'Henuz ceza yok.',
      'open_amount': 'Acik: {value} €',
      'paid_amount': 'Odendi: {value} €',
      'total_amount': 'Toplam: {value} €',
      'close': 'Kapat',
      'fine_catalog_empty': 'Ceza katalogu bos. Lutfen once kural ekleyin.',
      'assign_fine': 'Ceza ata',
      'step_1_player': '1. Oyuncu sec:',
      'step_2_offense': '2. Katalogdan ihlal sec:',
      'step_3_payment': '3. Odeme durumu:',
      'already_paid': 'Zaten odendi',
      'book_fine': 'Ceza kaydet',
      'fine_recorded_for': '{name} icin ceza basariyla kaydedildi!',
      'fine_catalog': 'Ceza katalogu',
      'delete_rule': 'Kurali sil',
      'catalog_admin_only':
          'Katalogu sadece kulup yoneticileri duzenleyebilir.',
      'add_new_rule': 'Yeni kural ekle',
      'rule_description': 'Kural aciklamasi',
      'fine_amount_label': 'Ceza (orn. 5,00)',
      'add': 'Ekle',
      'profile_title': 'Profil',
      'own_account': 'Kendi hesap',
      'role_label': 'Rol: {role}',
      'open_team_cash': 'Acik takim kasasi',
      'next_7_days': 'Sonraki 7 gun',
      'appointments_count': '{count} etkinlik',
      'open_votes': 'Acik oylamalar',
      'month': 'Ay',
      'events_on_date': '{date} tarihindeki etkinlikler',
      'clear_filter': 'Filtreyi temizle',
      'no_events_selected_day': 'Secilen gunde etkinlik yok.',
      'no_upcoming_in_category': 'Bu kategoride yaklasan etkinlik yok.',
      'past_events': 'Gecmis etkinlikler',
      'delete_event': 'Etkinligi sil',
      'confirm_delete_event': 'Bu etkinligi silmek istiyor musun?',
      'deleted': 'Silindi',
      'event_deleted': 'Etkinlik silindi',
      'event_created': 'Etkinlik olusturuldu',
      'event_updated': 'Etkinlik guncellendi',
      'series_created_count': '{count} seri etkinlik olusturuldu',
      'justify_status': '{status} durumunu acikla',
      'coach_requires_reason': 'Antrenor bu durum icin aciklama istiyor:',
      'reason_hint': 'orn. hasta, sakatlik, okul...',
      'min_5_chars': 'En az 5 karakter gerekli.',
      'edit_team_photo': 'Takim fotografini duzenle',
      'choose_photo': 'Fotograf sec',
      'remove_photo': 'Fotografi kaldir',
      'choose_bg_color': 'Veya arka plan rengi sec:',
      'image_caption': 'Resim aciklamasi',
      'crest_admin_only': 'Armayi sadece kulup yoneticisi degistirebilir.',
      'edit_crest': 'Kulup armasini duzenle',
      'choose_image': 'Resim sec',
      'remove_image': 'Resmi kaldir',
      'choose_crest_color': 'Veya arma rengi sec:',
      'import_members': 'Uyeleri ice aktar',
      'import_excel_csv': 'Excel / CSV listesini ice aktar',
      'enter_players_manually': 'Oyunculari manuel gir',
      'squad_availability': 'Kadro uygunlugu',
      'no_feedback_yet': 'Henuz geri bildirim yok.',
      'registered_count': 'KATILAN ({count})',
      'uncertain_count': 'BELIRSIZ ({count})',
      'canceled_count': 'IPTAL ({count})',
      'no_confirmations': 'Katilim yok',
      'no_uncertain_feedback': 'Belirsiz donus yok',
      'no_cancellations': 'Iptal yok',
      'edit_event_form': 'Etkinligi duzenle',
      'new_event_form': 'Yeni etkinlik olustur',
      'event_name_required': 'Etkinlik adi *',
      'date_required': 'Tarih (GG.AA) *',
      'start_time_required': 'Baslangic saati (SS:DD) *',
      'meeting_time_optional': 'Bulusma saati (opsiyonel)',
      'end_time_optional': 'Bitis saati (opsiyonel)',
      'sports_facility_required': 'Saha / adres *',
      'note_label': 'Not',
      'series_event_label': 'Seri etkinlik olarak olustur',
      'duration_weeks': 'Sure (hafta): {weeks}',
      'nominate_roles': 'Rolleri belirle',
      'email_notify': 'Aday oyunculara e-posta gonder',
      'push_notify': 'Aday oyunculara push bildirimi gonder',
      'reason_required_cancel': 'Iptalde gerekce zorunlu:',
      'fill_required_correctly': 'Lutfen tum zorunlu alanlari dogru doldurun.',
      'end_must_be_after_start': 'Bitis saati baslangictan sonra olmali.',
      'open_calendar': 'Takvimi ac',
      'select_time': 'Saat sec',
      'select_meeting_time': 'Bulusma saatini sec',
      'select_end_time': 'Bitis saatini sec',
      'welcome_back': 'Tekrar hos geldin!',
      'u15_dashboard': 'U15 Paneli',
      'my_role': 'Rolum:',
      'open_vote_banner_title': 'Acik oylama',
      'open_vote_banner_text': '{count} acik oylama var.',
      'open_amount_banner_title': 'Acik tutar',
      'open_amount_banner_text': '{amount} € borcun var.',
      'next_events': 'Siradaki etkinlikler',
      'show_all': 'Tumunu goster',
      'no_events_next_7_days': 'Sonraki 7 gunde etkinlik yok.',
      'live_table_title': 'Canli puan tablosu (Fussball.de API)',
      'back_to_overview': 'Genel gorunume don',
      'team_center': 'Takim merkezi',
      'squad_admin_finance': 'Kadro yonetimi ve finans',
      'cash_status': 'Kasa durumu',
      'rules': 'Kurallar',
      'entries_count': '{count} kayit',
      'top_scorer': 'En golcu',
      'cards': 'Kartlar',
      'yellow_red_cards': '{yellow} sari / {red} kirmizi',
      'team_cash_desc': 'Ceza, bakiye ve tum gelir/giderlerin ozeti.',
      'rules_catalog_title': 'Kurallar (ceza katalogu)',
      'rules_catalog_desc':
          'Dakiklik ve fair play icin baglayici davranis kodu.',
      'statistics': 'Istatistik',
      'statistics_desc': 'Katilim, gol ve asist analizleri.',
      'cards_desc': 'Takimdaki sari ve kirmizi kartlari yonet.',
      'squad_statistics': 'Kadro istatistikleri',
      'best_assists': 'En iyi asist',
      'avg_participation_short': 'Ort. katilim',
      'individual_stats': 'Bireysel istatistikler',
      'player': 'Oyuncu',
      'goals_short': 'G',
      'assists_short': 'A',
      'participation_short': 'Katil.',
      'analysis': 'Analiz',
      'top_scorer_analysis': 'En golcu: {name} - {goals} gol',
      'best_assists_analysis': 'En iyi asist: {name} - {assists} asist',
      'avg_participation_analysis': 'Ortalama antrenman katilimi: {value} %',
      'module_opened': '"{title}" modulu acildi.',
      'delete_appointment_tooltip': 'Etkinligi sil',
      'view_participants_tooltip': 'Katilimcilari gor',
      'meeting_label': 'Toplanma',
      'start_label': 'Baslangic',
      'end_label': 'Bitis',
      'place_label': 'Yer',
      'note_detail_label': 'Not',
      'not_specified': 'Belirtilmedi',
      'no_note_available': 'Not yok',
      'join_action': 'Katil',
      'unsure_action': 'Kararsiz',
      'decline_action': 'Ayril',
      'termin_select_title': 'Etkinlik turu sec',
      'termin_select_subtitle': 'Etkinligi nasil olusturmak istersin?',
      'manual_create_section': 'Manuel olusturma',
      'fussball_import_title': 'FUSSBALL.DE arayuzu',
      'fussball_import_info':
          'Fikstur aktarimi: Takimin maclarini FUSSBALL.DE uzerinden birkac tikla ice aktar.',
      'fussball_import_button': 'FUSSBALL.DE uzerinden ice aktar',
      'fussball_import_done':
          'FUSSBALL.DE baglantisi kuruluyor... Fikstur yuklendi.',
      'type_training': 'Antrenman',
      'type_game': 'Mac',
      'type_tournament': 'Turnuva',
      'type_event': 'Etkinlik',
      'create_fullscreen_title': 'Etkinlik olustur',
      'fussball_import_loading': 'Ice aktarma suruyor...',
      'fussball_import_failed':
          'FUSSBALL.DE ice aktarma basarisiz oldu. Lutfen tekrar deneyin.',
    },
  };

  String t(String key) {
    final lang = _localized[locale.languageCode] ?? _localized['de']!;
    return lang[key] ?? _localized['de']![key] ?? key;
  }
}

class _AppI18nDelegate extends LocalizationsDelegate<AppI18n> {
  const _AppI18nDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppI18n.supportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppI18n> load(Locale locale) async {
    return AppI18n(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppI18n> old) => false;
}

void main() {
  runApp(const VereinsApp());
}

class VereinsApp extends StatefulWidget {
  const VereinsApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_VereinsAppState>();
    state?.setLocale(locale);
  }

  @override
  State<VereinsApp> createState() => _VereinsAppState();
}

class AuthResult {
  final bool success;
  final bool pending;
  final bool requiresPasswordChange;
  final String? fullName;
  final String? email;
  final String message;

  const AuthResult({
    required this.success,
    required this.pending,
    this.requiresPasswordChange = false,
    required this.message,
    this.fullName,
    this.email,
  });
}

class _VereinsAppState extends State<VereinsApp> {
  static const String _kLastLoggedInEmailKey = 'last_logged_in_email';
  static const String _kMembersKey = 'auth_members';
  static const String _kWaitingAccountsKey = 'auth_waiting_accounts';
  static const String _kApprovalAuditKey = 'auth_approval_audit';

  Locale _locale = const Locale('de');
  String? _loggedInUserName;
  String? _forcedPasswordChangeEmail;
  String? _forcedPasswordChangeName;
  final bool _bypassLoginForDev = false;
  bool _isLoadingSession = true;
  int _nextMemberId = 10000;

  final List<Map<String, dynamic>> _vereinsMitglieder = [
    {
      'id': 10000,
      'name': 'Mert Eligüzel',
      'email': 'mert@verein.de',
      'rolle': 'Vereinsadministrator',
      'rollen': ['Vereinsadministrator'],
      'kontakt': 'mert@verein.de',
      'phone': '+49 152 2345678',
      'erlaubteTeams': ['all'],
      'passwort': 'Admin#2026',
      'mustChangePassword': false,
    },
    {
      'id': 10001,
      'name': 'Pascal Camara',
      'email': 'camarapascal11@gmail.com',
      'rolle': 'Vereinsadministrator',
      'rollen': ['Vereinsadministrator', 'Trainer', 'Spieler'],
      'kontakt': 'camarapascal11@gmail.com',
      'phone': '+49 152 0128022004',
      'erlaubteTeams': ['all'],
      'passwort': 'Camara28022004',
      'mustChangePassword': false,
    },
    {
      'id': 10002,
      'name': 'Bernd Süring',
      'email': 'b.suering@tvfriedrichstein.de',
      'rolle': '1. Vorsitzender (Vorstand)',
      'rollen': ['Vorstand'],
      'kontakt': 'Vorstand',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10003,
      'name': 'Uli Harms',
      'email': 'u.harms@tvfriedrichstein.de',
      'rolle': 'Vorstand',
      'rollen': ['Vorstand'],
      'kontakt': 'Vorstand',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10004,
      'name': 'Hans-Jürgen Kramer',
      'email': 'hj.kramer@tvfriedrichstein.de',
      'rolle': 'Vorstand',
      'rollen': ['Vorstand'],
      'kontakt': 'Vorstand',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10005,
      'name': 'Andreas Brüne',
      'email': 'a.bruene@tvfriedrichstein.de',
      'rolle': 'Vorstand',
      'rollen': ['Vorstand'],
      'kontakt': 'Vorstand',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10006,
      'name': 'Dean Schrauf',
      'email': 'd.schrauf@tvfriedrichstein.de',
      'rolle': 'Mitgliederverwaltung / Alte Herren',
      'rollen': ['Vorstand'],
      'kontakt': 'Mitgliederverwaltung',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10007,
      'name': 'Frank Lange',
      'email': 'f.lange@tvfriedrichstein.de',
      'rolle': 'Spartenleiter Jugendfußball',
      'rollen': ['Funktionär', 'Trainer'],
      'kontakt': 'Jugendfußball',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10008,
      'name': 'Michael Neuhaus',
      'email': 'm.neuhaus@tvfriedrichstein.de',
      'rolle': 'Spartenleiter Seniorenfußball',
      'rollen': ['Funktionär'],
      'kontakt': 'Seniorenfußball',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10009,
      'name': 'Daniela Wende',
      'email': 'd.wende@tvfriedrichstein.de',
      'rolle': 'Spartenleiter Frauenfußball',
      'rollen': ['Funktionär'],
      'kontakt': 'Frauenfußball',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10010,
      'name': 'Simone Jungermann',
      'email': 's.jungermann@tvfriedrichstein.de',
      'rolle': 'Spartenleiter Fitness / Men-Power',
      'rollen': ['Funktionär'],
      'kontakt': 'Fitness',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
  ];

  static const List<Map<String, dynamic>> _fixedBoardSeedMembers = [
    {
      'id': 10000,
      'name': 'Mert Eligüzel',
      'email': 'mert@verein.de',
      'rolle': 'Vereinsadministrator',
      'rollen': ['Vereinsadministrator'],
      'kontakt': 'mert@verein.de',
      'phone': '+49 152 2345678',
      'erlaubteTeams': ['all'],
      'passwort': 'Admin#2026',
      'mustChangePassword': false,
    },
    {
      'id': 10001,
      'name': 'Pascal Camara',
      'email': 'camarapascal11@gmail.com',
      'rolle': 'Vereinsadministrator',
      'rollen': ['Vereinsadministrator', 'Trainer', 'Spieler'],
      'kontakt': 'camarapascal11@gmail.com',
      'phone': '+49 152 0128022004',
      'erlaubteTeams': ['all'],
      'passwort': 'Camara28022004',
      'mustChangePassword': false,
    },
    {
      'id': 10002,
      'name': 'Bernd Süring',
      'email': 'b.suering@tvfriedrichstein.de',
      'rolle': '1. Vorsitzender (Vorstand)',
      'rollen': ['Vorstand'],
      'kontakt': 'Vorstand',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10003,
      'name': 'Uli Harms',
      'email': 'u.harms@tvfriedrichstein.de',
      'rolle': 'Vorstand',
      'rollen': ['Vorstand'],
      'kontakt': 'Vorstand',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10004,
      'name': 'Hans-Jürgen Kramer',
      'email': 'hj.kramer@tvfriedrichstein.de',
      'rolle': 'Vorstand',
      'rollen': ['Vorstand'],
      'kontakt': 'Vorstand',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10005,
      'name': 'Andreas Brüne',
      'email': 'a.bruene@tvfriedrichstein.de',
      'rolle': 'Vorstand',
      'rollen': ['Vorstand'],
      'kontakt': 'Vorstand',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10006,
      'name': 'Dean Schrauf',
      'email': 'd.schrauf@tvfriedrichstein.de',
      'rolle': 'Mitgliederverwaltung / Alte Herren',
      'rollen': ['Vorstand'],
      'kontakt': 'Mitgliederverwaltung',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10007,
      'name': 'Frank Lange',
      'email': 'f.lange@tvfriedrichstein.de',
      'rolle': 'Spartenleiter Jugendfußball',
      'rollen': ['Funktionär', 'Trainer'],
      'kontakt': 'Jugendfußball',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10008,
      'name': 'Michael Neuhaus',
      'email': 'm.neuhaus@tvfriedrichstein.de',
      'rolle': 'Spartenleiter Seniorenfußball',
      'rollen': ['Funktionär'],
      'kontakt': 'Seniorenfußball',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10009,
      'name': 'Daniela Wende',
      'email': 'd.wende@tvfriedrichstein.de',
      'rolle': 'Spartenleiter Frauenfußball',
      'rollen': ['Funktionär'],
      'kontakt': 'Frauenfußball',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
    {
      'id': 10010,
      'name': 'Simone Jungermann',
      'email': 's.jungermann@tvfriedrichstein.de',
      'rolle': 'Spartenleiter Fitness / Men-Power',
      'rollen': ['Funktionär'],
      'kontakt': 'Fitness',
      'phone': '-',
      'erlaubteTeams': ['all'],
      'passwort': '',
      'mustChangePassword': false,
    },
  ];

  final List<Map<String, dynamic>> _wartendeKonten = [];
  final List<Map<String, dynamic>> _freigabeAuditLog = [];

  String _hashPassword(String raw) {
    final input = 'clubapp::salt::${raw.trim()}';
    return sha256.convert(utf8.encode(input)).toString();
  }

  int _allocateMemberId() {
    final id = _nextMemberId;
    _nextMemberId++;
    return id;
  }

  void _recomputeNextMemberId() {
    int maxId = 9999;
    for (final member in _vereinsMitglieder) {
      final id = int.tryParse(member['id']?.toString() ?? '');
      if (id != null && id > maxId) {
        maxId = id;
      }
    }
    _nextMemberId = maxId + 1;
  }

  void _normalizeAuthLists() {
    for (final member in _vereinsMitglieder) {
      member['id'] ??= _allocateMemberId();
      final normalizedEmail =
          ((member['email'] ?? member['kontakt'])?.toString() ?? '')
              .trim()
              .toLowerCase();
      final existingContact = member['kontakt']?.toString().trim() ?? '';
      member['email'] = normalizedEmail;
      member['kontakt'] = existingContact.isEmpty
          ? normalizedEmail
          : existingContact;
      member['mustChangePassword'] = member['mustChangePassword'] == true;
      final rawRoles =
          (member['rollen'] as List?)
              ?.map((role) => role.toString().trim())
              .where((role) => role.isNotEmpty)
              .toList() ??
          <String>[];
      final primaryRole = (member['rolle']?.toString().trim() ?? '').trim();
      final normalizedRoles = <String>{
        if (primaryRole.isNotEmpty) primaryRole,
        ...rawRoles,
      }.toList();
      member['rollen'] = normalizedRoles.isNotEmpty
          ? normalizedRoles
          : <String>[primaryRole.isNotEmpty ? primaryRole : 'Spieler'];
      member['rolle'] = primaryRole.isNotEmpty
          ? primaryRole
          : member['rollen'].first as String;

      final legacyPassword = member['passwort']?.toString();
      if (member['passwordHash'] == null &&
          legacyPassword != null &&
          legacyPassword.isNotEmpty) {
        member['passwordHash'] = _hashPassword(legacyPassword);
      }

      final allowedRaw = (member['erlaubteTeams'] as List?) ?? <dynamic>[];
      member['erlaubteTeams'] = allowedRaw.map((e) => e.toString()).toList();
    }

    for (final waiting in _wartendeKonten) {
      final legacyPassword = waiting['passwort']?.toString();
      if (waiting['passwordHash'] == null && legacyPassword != null) {
        waiting['passwordHash'] = _hashPassword(legacyPassword);
      }
      waiting['email'] = (waiting['email']?.toString() ?? '').toLowerCase();
      waiting['status'] = 'Nicht zugewiesen';
    }

    _ensureSeedAuthAccount();
    _syncFixedBoardMembers();
    _recomputeNextMemberId();
  }

  void _syncFixedBoardMembers() {
    for (final seed in _fixedBoardSeedMembers) {
      final seedId = seed['id'];
      final index = _vereinsMitglieder.indexWhere(
        (member) => member['id'] == seedId,
      );

      if (index >= 0) {
        final existing = _vereinsMitglieder[index];
        final passwordHash = existing['passwordHash'];
        final mustChangePassword = existing['mustChangePassword'] == true;
        _vereinsMitglieder[index] = {
          ...seed,
          ...?passwordHash == null
              ? null
              : <String, dynamic>{'passwordHash': passwordHash},
          'mustChangePassword': mustChangePassword,
        };
      } else {
        _vereinsMitglieder.add(Map<String, dynamic>.from(seed));
      }
    }
  }

  void _ensureSeedAuthAccount() {
    final pascalIndex = _vereinsMitglieder.indexWhere(
      (member) =>
          (member['email']?.toString().toLowerCase() ?? '') ==
          'camarapascal11@gmail.com',
    );

    if (pascalIndex >= 0) {
      final member = _vereinsMitglieder[pascalIndex];
      member['name'] = 'Pascal Camara';
      member['rolle'] = 'Vereinsadministrator';
      member['rollen'] = ['Vereinsadministrator', 'Trainer', 'Spieler'];
      member['kontakt'] = 'camarapascal11@gmail.com';
      member['email'] = 'camarapascal11@gmail.com';
      member['erlaubteTeams'] = ['all'];
      member['mustChangePassword'] = member['mustChangePassword'] == true;
      return;
    }

    _vereinsMitglieder.add({
      'id': _allocateMemberId(),
      'name': 'Pascal Camara',
      'email': 'camarapascal11@gmail.com',
      'rolle': 'Vereinsadministrator',
      'rollen': ['Vereinsadministrator', 'Trainer', 'Spieler'],
      'kontakt': 'camarapascal11@gmail.com',
      'phone': '+49 152 0128022004',
      'erlaubteTeams': ['all'],
      'passwort': 'Camara28022004',
      'passwordHash': _hashPassword('Camara28022004'),
      'mustChangePassword': false,
    });
  }

  bool _matchesPassword(Map<String, dynamic> entity, String password) {
    final plain = entity['passwort']?.toString() ?? '';
    if (plain.isNotEmpty && plain == password) {
      return true;
    }

    final storedHash = entity['passwordHash']?.toString();
    if (storedHash == null || storedHash.isEmpty) {
      return false;
    }
    return storedHash == _hashPassword(password);
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    _restoreAuthState();
  }

  Future<void> _restoreAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMembers = prefs.getString(_kMembersKey);
    final savedWaiting = prefs.getString(_kWaitingAccountsKey);
    final savedAudit = prefs.getString(_kApprovalAuditKey);
    final savedEmail = prefs.getString(_kLastLoggedInEmailKey);

    if (savedMembers != null && savedMembers.isNotEmpty) {
      try {
        final decoded = jsonDecode(savedMembers);
        if (decoded is List) {
          _vereinsMitglieder
            ..clear()
            ..addAll(
              decoded.whereType<Map>().map((m) => Map<String, dynamic>.from(m)),
            );
        }
      } catch (_) {
        // Ignore invalid persisted auth data.
      }
    }

    if (savedWaiting != null && savedWaiting.isNotEmpty) {
      try {
        final decoded = jsonDecode(savedWaiting);
        if (decoded is List) {
          _wartendeKonten
            ..clear()
            ..addAll(
              decoded.whereType<Map>().map((m) => Map<String, dynamic>.from(m)),
            );
        }
      } catch (_) {
        // Ignore invalid persisted waiting data.
      }
    }

    if (savedAudit != null && savedAudit.isNotEmpty) {
      try {
        final decoded = jsonDecode(savedAudit);
        if (decoded is List) {
          _freigabeAuditLog
            ..clear()
            ..addAll(
              decoded.whereType<Map>().map((m) => Map<String, dynamic>.from(m)),
            );
        }
      } catch (_) {
        // Ignore invalid persisted audit data.
      }
    }

    _normalizeAuthLists();

    if (savedEmail != null) {
      Map<String, dynamic>? member;
      for (final m in _vereinsMitglieder) {
        if ((m['email']?.toString() ?? '') == savedEmail) {
          member = m;
          break;
        }
      }
      if (member != null && member['mustChangePassword'] == true) {
        _forcedPasswordChangeEmail = member['email'] as String?;
        _forcedPasswordChangeName = member['name'] as String?;
      } else {
        _loggedInUserName = member?['name'] as String?;
      }
    }

    await _persistAuthLists();

    if (!mounted) return;
    setState(() {
      _isLoadingSession = false;
    });
  }

  Future<void> _persistAuthLists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMembersKey, jsonEncode(_vereinsMitglieder));
    await prefs.setString(_kWaitingAccountsKey, jsonEncode(_wartendeKonten));
    await prefs.setString(_kApprovalAuditKey, jsonEncode(_freigabeAuditLog));
  }

  Future<void> _persistLoginEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null || email.isEmpty) {
      await prefs.remove(_kLastLoggedInEmailKey);
    } else {
      await prefs.setString(_kLastLoggedInEmailKey, email);
    }
  }

  Future<AuthResult> _login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    Map<String, dynamic>? approved;
    for (final m in _vereinsMitglieder) {
      final memberEmail =
          ((m['email'] ?? m['kontakt'])?.toString().toLowerCase() ?? '');
      if (memberEmail == normalizedEmail &&
          _matchesPassword(m, normalizedPassword)) {
        approved = m;
        break;
      }
    }

    if (approved != null) {
      final mustChange = approved['mustChangePassword'] == true;
      final fullName = approved['name'] as String;
      final memberEmail =
          ((approved['email'] ?? approved['kontakt'])?.toString() ?? '')
              .toLowerCase();
      if (mustChange) {
        return AuthResult(
          success: false,
          pending: false,
          requiresPasswordChange: true,
          fullName: fullName,
          email: memberEmail,
          message:
              'Du musst dein temporaeres Start-Passwort jetzt aktualisieren.',
        );
      }

      _loggedInUserName = fullName;
      await _persistLoginEmail(normalizedEmail);
      return AuthResult(
        success: true,
        pending: false,
        fullName: fullName,
        email: memberEmail,
        message: 'Anmeldung erfolgreich.',
      );
    }

    Map<String, dynamic>? waiting;
    for (final k in _wartendeKonten) {
      final waitingEmail = (k['email']?.toString().toLowerCase() ?? '');
      if (waitingEmail == normalizedEmail &&
          _matchesPassword(k, normalizedPassword)) {
        waiting = k;
        break;
      }
    }

    if (waiting != null) {
      return const AuthResult(
        success: false,
        pending: true,
        message:
            'Dein Konto wurde erfolgreich registriert. Bitte warte, bis dein Trainer oder Vereins-Admin dich einer Mannschaft zuweist.',
      );
    }

    return const AuthResult(
      success: false,
      pending: false,
      message: 'Anmeldung fehlgeschlagen. Bitte pruefe E-Mail und Passwort.',
    );
  }

  Future<String?> _register(
    String fullName,
    String email,
    String password,
  ) async {
    return 'Selbstregistrierung ist deaktiviert. Bitte wende dich an Trainer oder Vereins-Admin.';
  }

  Future<String> _resetPassword(String email, String newPassword) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = newPassword.trim();

    if (!normalizedEmail.contains('@')) {
      return 'Bitte eine gueltige E-Mail-Adresse eingeben.';
    }
    if (normalizedPassword.length < 6) {
      return 'Das neue Passwort muss mindestens 6 Zeichen haben.';
    }

    Map<String, dynamic>? member;
    for (final m in _vereinsMitglieder) {
      final memberEmail =
          ((m['email'] ?? m['kontakt'])?.toString().toLowerCase() ?? '');
      if (memberEmail == normalizedEmail) {
        member = m;
        break;
      }
    }
    if (member != null) {
      member['passwort'] = normalizedPassword;
      member['passwordHash'] = _hashPassword(normalizedPassword);
      member['mustChangePassword'] = false;
      await _persistAuthLists();
      return 'Passwort wurde erfolgreich aktualisiert.';
    }

    Map<String, dynamic>? waiting;
    for (final k in _wartendeKonten) {
      if ((k['email']?.toString().toLowerCase() ?? '') == normalizedEmail) {
        waiting = k;
        break;
      }
    }
    if (waiting != null) {
      waiting['passwordHash'] = _hashPassword(normalizedPassword);
      await _persistAuthLists();
      return 'Passwort fuer wartendes Konto aktualisiert.';
    }

    return 'Kein Konto mit dieser E-Mail gefunden.';
  }

  Future<void> _logout() async {
    setState(() {
      _loggedInUserName = null;
      _forcedPasswordChangeEmail = null;
      _forcedPasswordChangeName = null;
    });
    await _persistLoginEmail(null);
  }

  Future<void> _activateForcedPasswordChange(AuthResult result) async {
    final email = (result.email ?? '').trim().toLowerCase();
    final fullName = (result.fullName ?? '').trim();
    if (email.isEmpty || fullName.isEmpty) return;

    setState(() {
      _loggedInUserName = null;
      _forcedPasswordChangeEmail = email;
      _forcedPasswordChangeName = fullName;
    });
    await _persistLoginEmail(email);
  }

  Future<String?> _completeForcedPasswordChange(
    String email,
    String newPassword,
    String confirmPassword,
  ) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = newPassword.trim();
    final normalizedConfirm = confirmPassword.trim();

    if (normalizedPassword.length < 6) {
      return 'Das neue Passwort muss mindestens 6 Zeichen haben.';
    }
    if (normalizedPassword != normalizedConfirm) {
      return 'Passwort und Bestaetigung stimmen nicht ueberein.';
    }

    Map<String, dynamic>? member;
    for (final m in _vereinsMitglieder) {
      final memberEmail =
          ((m['email'] ?? m['kontakt'])?.toString().toLowerCase() ?? '');
      if (memberEmail == normalizedEmail) {
        member = m;
        break;
      }
    }

    if (member == null) {
      return 'Konto nicht gefunden. Bitte erneut anmelden.';
    }

    final oldPlain = (member['passwort']?.toString() ?? '').trim();
    final sameAsOldPlain =
        oldPlain.isNotEmpty && oldPlain == normalizedPassword;
    final sameAsOldHash =
        (member['passwordHash']?.toString() ?? '') ==
        _hashPassword(normalizedPassword);
    if (sameAsOldPlain || sameAsOldHash) {
      return 'Das neue Passwort darf nicht dem temporaeren Start-Passwort entsprechen.';
    }

    member['passwort'] = normalizedPassword;
    member['passwordHash'] = _hashPassword(normalizedPassword);
    member['mustChangePassword'] = false;

    await _persistAuthLists();
    await _persistLoginEmail(normalizedEmail);

    if (!mounted) return null;
    setState(() {
      _forcedPasswordChangeEmail = null;
      _forcedPasswordChangeName = null;
      _loggedInUserName = member?['name']?.toString() ?? '';
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vereins App',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: AppI18n.supportedLocales,
      localizationsDelegates: const [
        _AppI18nDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
        cardColor: kCardColor,
        colorScheme: ColorScheme.dark(
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white38,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.disabled)
                  ? Colors.white38
                  : Colors.white;
            }),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.disabled)
                  ? Colors.white38
                  : Colors.white;
            }),
            side: WidgetStateProperty.resolveWith((states) {
              return BorderSide(
                color: states.contains(WidgetState.disabled)
                    ? Colors.white24
                    : Colors.white38,
              );
            }),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      home: _isLoadingSession
          ? const Scaffold(
              backgroundColor: kBackgroundColor,
              body: Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              ),
            )
          : _bypassLoginForDev
          ? DashboardScreen(
              initialUserName:
                  _loggedInUserName ??
                  (_vereinsMitglieder.first['name'] as String? ??
                      'Mert Eliguzel'),
              vereinsMitglieder: _vereinsMitglieder,
              wartendeKonten: _wartendeKonten,
              freigabeAuditLog: _freigabeAuditLog,
              onAuthDataChanged: _persistAuthLists,
              onLogout: _logout,
            )
          : _loggedInUserName == null
          ? _forcedPasswordChangeEmail != null
                ? ForcedPasswordChangeScreen(
                    fullName: _forcedPasswordChangeName ?? '',
                    email: _forcedPasswordChangeEmail!,
                    onSubmit: _completeForcedPasswordChange,
                  )
                : AuthScreen(
                    onLogin: _login,
                    onRegister: _register,
                    onResetPassword: _resetPassword,
                    onRequirePasswordChange: (result) {
                      unawaited(_activateForcedPasswordChange(result));
                    },
                    onLoginSuccess: (fullName) {
                      setState(() {
                        _loggedInUserName = fullName;
                        _forcedPasswordChangeEmail = null;
                        _forcedPasswordChangeName = null;
                      });
                    },
                  )
          : DashboardScreen(
              initialUserName: _loggedInUserName!,
              vereinsMitglieder: _vereinsMitglieder,
              wartendeKonten: _wartendeKonten,
              freigabeAuditLog: _freigabeAuditLog,
              onAuthDataChanged: _persistAuthLists,
              onLogout: _logout,
            ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final Future<AuthResult> Function(String email, String password) onLogin;
  final Future<String?> Function(String fullName, String email, String password)
  onRegister;
  final Future<String> Function(String email, String newPassword)
  onResetPassword;
  final void Function(AuthResult result) onRequirePasswordChange;
  final void Function(String fullName) onLoginSuccess;

  const AuthScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
    required this.onResetPassword,
    required this.onRequirePasswordChange,
    required this.onLoginSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isBusy = false;
  String? _infoMessage;

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    setState(() {
      _isBusy = true;
      _infoMessage = null;
    });

    final result = await widget.onLogin(
      _loginEmailController.text,
      _loginPasswordController.text,
    );

    if (!mounted) return;
    if (result.requiresPasswordChange) {
      widget.onRequirePasswordChange(result);
      return;
    }
    if (result.success && result.fullName != null) {
      widget.onLoginSuccess(result.fullName!);
      return;
    }

    setState(() {
      _isBusy = false;
      _infoMessage = result.message;
    });
  }

  Future<void> _showResetPasswordDialog() async {
    final emailController = TextEditingController(
      text: _loginEmailController.text.trim(),
    );
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: const Text(
          'Passwort zuruecksetzen',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: SizedBox(
          width: adaptiveDialogWidth(context),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-Mail-Adresse',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Neues Passwort',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Abbrechen',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () async {
              final message = await widget.onResetPassword(
                emailController.text,
                passwordController.text,
              );
              if (!mounted || !context.mounted) return;
              Navigator.pop(context);
              setState(() {
                _infoMessage = message;
              });
            },
            child: const Text('Zuruecksetzen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const title = 'Anmelden';
    const subtitle =
        'Konten werden vorab von Trainern oder Vereinsadministratoren angelegt.';

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                color: kCardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Colors.white12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/app_icon.png',
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _loginEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-Mail-Adresse',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _loginPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Passwort',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                          ),
                          onPressed: _isBusy ? null : _submitLogin,
                          child: _isBusy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Anmelden'),
                        ),
                      ),
                      TextButton(
                        onPressed: _isBusy ? null : _showResetPasswordDialog,
                        child: const Text('Passwort vergessen?'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hinweis: Neue Konten werden ausschliesslich durch Trainer, Betreuer oder Vereinsadministratoren erstellt.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      if (_infoMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _infoMessage!,
                            style: const TextStyle(color: Colors.orangeAccent),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForcedPasswordChangeScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final Future<String?> Function(
    String email,
    String newPassword,
    String confirmPassword,
  )
  onSubmit;

  const ForcedPasswordChangeScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.onSubmit,
  });

  @override
  State<ForcedPasswordChangeScreen> createState() =>
      _ForcedPasswordChangeScreenState();
}

class _ForcedPasswordChangeScreenState
    extends State<ForcedPasswordChangeScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isBusy = false;
  String? _message;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isBusy = true;
      _message = null;
    });

    final error = await widget.onSubmit(
      widget.email,
      _newPasswordController.text,
      _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isBusy = false;
        _message = error;
      });
      return;
    }

    setState(() {
      _isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                color: kCardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Colors.white12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Passwort aendern erforderlich',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Willkommen ${widget.fullName}. Du bist mit einem temporaeren Passwort angemeldet. Bitte setze jetzt sofort ein neues Passwort.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Neues Passwort',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Passwort bestaetigen',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Regeln: mindestens 6 Zeichen und nicht identisch mit dem temporaeren Start-Passwort.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                          ),
                          onPressed: _isBusy ? null : _submit,
                          child: _isBusy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Passwort aktualisieren'),
                        ),
                      ),
                      if (_message != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _message!,
                            style: const TextStyle(color: Colors.orangeAccent),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String initialUserName;
  final List<Map<String, dynamic>> vereinsMitglieder;
  final List<Map<String, dynamic>> wartendeKonten;
  final List<Map<String, dynamic>> freigabeAuditLog;
  final Future<void> Function()? onAuthDataChanged;
  final VoidCallback? onLogout;

  const DashboardScreen({
    super.key,
    required this.initialUserName,
    required this.vereinsMitglieder,
    required this.wartendeKonten,
    required this.freigabeAuditLog,
    this.onAuthDataChanged,
    this.onLogout,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const String _kVereinsWappenColorKey = 'vereins_wappen_color';
  static const String _kVereinsWappenImageKey = 'vereins_wappen_image_base64';
  static const String _kLastTeamByUserKey = 'last_team_by_user';
  static const Color _kWhatsAppColor = Color(0xFF25D366);
  static const List<String> _kBroadcastAllowedRoles = [
    'Trainer',
    'Co-Trainer',
    'Betreuer',
    'Vereinsadministrator',
  ];

  int _selectedIndex = 0; // 0 = Dashboard/Home, Buttons unten schalten Tabs um
  String _currentUserRole = 'Spieler';
  String _currentUserName = 'Lian';
  String _currentKommSubView =
      'overview'; // 'overview', 'chats', 'anmerkungen', 'abstimmungen', 'active_chat', 'new_chat_select'
  String _selectedChatTitle = '';
  String _currentWappenSubView =
      'closed'; // 'closed', 'overview', 'news', 'members', 'feedback', 'account_linking', 'approval_audit', 'create_user', 'vereins_management_dashboard', 'vereins_formulare', 'trainings_planer'
  String _terminFilterType = 'Alle';
  DateTime _terminCalendarFocusedDay = DateTime.now();
  DateTime? _terminCalendarSelectedDay;

  final Map<String, double> _playerDebts = {
    'Lian': 5.00,
    'Mika': 0.00,
    'Kian': 3.50,
    'Jonas': 0.00,
    'Felix': 0.00,
  };

  final List<Map<String, dynamic>> _messages = [
    {
      'chat': 'Trainerchat',
      'sender': 'Co-Trainer',
      'text': 'Wer übernimmt heute das Aufwärmen?',
      'time': '12:01 Uhr',
    },
    {
      'chat': 'Elternchat',
      'sender': 'Mutter von Mika',
      'text':
          'Fährt heute jemand über die Hauptstraße und kann Mika mitnehmen?',
      'time': '11:45 Uhr',
    },
    {
      'chat': 'Spielerchat',
      'sender': 'Lian',
      'text': 'Bringen wir heute die roten oder schwarzen Trainingsshirts mit?',
      'time': '12:10 Uhr',
    },
    {
      'chat': 'Allgemeiner Chat',
      'sender': 'Betreuer',
      'text': 'Denkt an die Schienbeinschoner für das Testspiel am Mittwoch!',
      'time': '09:30 Uhr',
    },
  ];

  final List<Map<String, dynamic>> _aktivePrivatChats = [
    {'name': 'Mert Eligüzel', 'subtitle': 'Online'},
    {'name': 'Kevin Glöckler', 'subtitle': 'Zuletzt online vor 2 Std.'},
  ];

  final List<String> _chatAuswahlMitglieder = [
    'Mert Eligüzel',
    'Kevin Glöckler',
    'Lian',
    'Mika',
    'Jonas',
    'Kian',
    'Felix',
    'Günter Lehmann',
  ];

  String _chatMemberSearch = '';
  final List<Map<String, dynamic>> _eingereichteAnmerkungen = [
    {
      'kategorie': 'Anmerkung zum Training',
      'text': 'Die Taktikübungen am Dienstag waren echt super verständlich.',
      'anonym': true,
      'autor': 'Anonym',
    },
    {
      'kategorie': 'Probleme',
      'text': 'Das Flutlicht auf Platz 2 flackert hinten rechts ein wenig.',
      'anonym': false,
      'autor': 'Kevin (Betreuer)',
    },
  ];

  late final List<Map<String, dynamic>> _vereinsMitglieder;
  late final List<Map<String, dynamic>> _wartendeKonten;
  late final List<Map<String, dynamic>> _freigabeAuditLog;

  final List<Map<String, dynamic>> _vereinsFeedback = [
    {
      'title': 'Beschwerde: Platzpflege',
      'status': 'Offen',
      'message': 'Der Rasen im rechten Strafraum ist sehr hart und uneben.',
      'submittedBy': 'Mika',
      'date': '22.06.2026',
    },
    {
      'title': 'Feedback: Getränkestand',
      'status': 'Bearbeitet',
      'message': 'Bitte den Getränkestand beim Heimspiel besser organisieren.',
      'submittedBy': 'Jonas',
      'date': '21.06.2026',
    },
  ];

  final List<Map<String, dynamic>> _vereinsFormulare = [
    {
      'id': 'f1',
      'titel': 'HFV Passantrag (Erstausstellung)',
      'kategorie': 'Passwesen',
      'dateiname': 'hfv_passantrag_2026.pdf',
      'path': '',
      'hochgeladenAm': '27.06.2026',
    },
    {
      'id': 'f2',
      'titel': 'Anmeldung Hauptverein (TV Friedrichstein)',
      'kategorie': 'Mitgliedschaft',
      'dateiname': 'verein_anmeldung_v2.pdf',
      'path': '',
      'hochgeladenAm': '15.05.2026',
    },
  ];

  final List<Map<String, dynamic>> _aktiveAbstimmungen = [
    {
      'id': 1,
      'titel': 'Treffpunkt fuer Auswaertsspiel am Samstag?',
      'zielgruppe': 'Spieler + Eltern',
      'allowMultipleAnswers': false,
      'optionen': [
        {'text': 'Direkt am Stadion', 'stimmen': 4},
        {'text': 'Gemeinsam am Vereinsheim', 'stimmen': 7},
      ],
      'voted': false,
    },
  ];

  final Map<int, Set<int>> _abstimmungsAuswahl = {};

  final List<Map<String, dynamic>> _trainingsEinheiten = [];
  final GlobalKey<FormState> _trainingFormKey = GlobalKey<FormState>();
  String _trainingsSchwerpunkt = 'Aufwaermen';
  double _trainingsZeitMinuten = 90;
  final TextEditingController _hauptuebung1Controller = TextEditingController();
  final TextEditingController _hauptuebung2Controller = TextEditingController();

  final List<Map<String, dynamic>> _terminGroups = [
    {'type': 'Alle', 'label': 'Alle'},
    {'type': 'Training', 'label': 'Training'},
    {'type': 'Spiel', 'label': 'Spiel'},
    {'type': 'Sonstiges', 'label': 'Sonstiges'},
  ];

  // --- NEUE VARIABLEN FÜR DEN TEAM-TAB ---
  String _currentTeamSubView =
      'uebersicht'; // 'uebersicht', 'overview', 'kasse', 'regeln', 'statistik', 'karten', 'mitglieder_liste'
  String _currentTerminSubView =
      'list'; // 'list', 'select_type', 'create_form', 'vorbereitung_overview'
  String _selectedTerminTypeForCreate = 'Training';
  bool _isImportingSpielplan = false;
  DateTime _statsVonDatum = DateTime.now().subtract(const Duration(days: 45));
  DateTime _statsBisDatum = DateTime.now();
  final Set<String> _aktivierteStatsTypen = {
    'Training',
    'Spiel',
    'Event',
    'Turnier',
  };
  final FussballDeImportRepository _fussballDeImportRepository =
      FussballDeImportRepository();
  String _dfbnetImportSelectedTeamId = 'c_jugend';
  String _dfbnetImportSaison = '2026/27';
  String _dfbnetImportResultMessage = '';
  bool _dfbnetImportResultSuccess = false;

  String _selectedTeamId = 'c_jugend';

  final List<Map<String, dynamic>> _vereinsTeams = [
    {
      'id': 'c_jugend',
      'name': 'C-Jugend Mannschaft',
      'saison': '2026/27',
      'spielerIds': <String>[],
      'photoCaption': 'C-Jugend Saison 2026',
      'photoColor': const Color(0xFF2563EB),
      'photoBytes': null,
      'fussballDeTeamId': 'tv-friedrichstein-c-jugend',
      'whatsappGroupId': '',
      'whatsappGroupInvite': '',
      'vorbereitungsPlan': null,
      'vorbereitungsDateien': <Map<String, dynamic>>[],
      'mitglieder': [
        {
          'name': 'Lian',
          'rolle': 'Spieler',
          'rueckennummer': 10,
          'starkerFuss': 'Rechts',
          'hauptposition': 'Sturm',
          'nebenposition': 'Offensives Mittelfeld',
          'elternname': 'Familie Lian',
          'notfallTelefon': '+49 151 1111111',
          'medizinischeHinweise': 'Keine bekannten Allergien',
          'scorecard': {
            'technik': 65,
            'taktik': 58,
            'fitness': 70,
            'mental': 75,
            'notizen':
                'Sehr trainingsfleissig, starker linker Fuss. Muss am Stellungsspiel arbeiten.',
            'letztesUpdate': '28.06.2026',
          },
        },
        {
          'name': 'Mika',
          'rolle': 'Spieler',
          'rueckennummer': 8,
          'starkerFuss': 'Links',
          'hauptposition': 'Mittelfeld',
          'nebenposition': 'Linksaußen',
          'elternname': 'Familie Mika',
          'notfallTelefon': '+49 151 2222222',
          'medizinischeHinweise': 'Leichte Pollenallergie',
          'scorecard': {
            'technik': 62,
            'taktik': 60,
            'fitness': 73,
            'mental': 71,
            'notizen':
                'Starke Dynamik im Dribbling, muss am ersten Kontakt arbeiten.',
            'letztesUpdate': '28.06.2026',
          },
        },
        {
          'name': 'Kian',
          'rolle': 'Spieler',
          'rueckennummer': 4,
          'starkerFuss': 'Beidfüßig',
          'hauptposition': 'Abwehr',
          'nebenposition': 'Defensives Mittelfeld',
          'elternname': 'Familie Kian',
          'notfallTelefon': '+49 151 3333333',
          'medizinischeHinweise': 'Bitte Rücksicht auf Asthma bei Belastung',
          'scorecard': {
            'technik': 59,
            'taktik': 66,
            'fitness': 68,
            'mental': 74,
            'notizen':
                'Sehr diszipliniert im Zweikampf, Timing beim Passspiel verbessern.',
            'letztesUpdate': '28.06.2026',
          },
        },
        {
          'name': 'Jonas',
          'rolle': 'Spieler',
          'rueckennummer': 2,
          'starkerFuss': 'Rechts',
          'hauptposition': 'Abwehr',
          'nebenposition': 'Außenverteidigung',
          'elternname': 'Familie Jonas',
          'notfallTelefon': '+49 151 4444444',
          'medizinischeHinweise': 'Keine Besonderheiten',
          'scorecard': {
            'technik': 57,
            'taktik': 63,
            'fitness': 69,
            'mental': 72,
            'notizen': 'Gute Defensivarbeit, braucht mehr Ruhe im Spielaufbau.',
            'letztesUpdate': '28.06.2026',
          },
        },
        {
          'name': 'Felix',
          'rolle': 'Spieler',
          'rueckennummer': 1,
          'starkerFuss': 'Rechts',
          'hauptposition': 'Torwart',
          'nebenposition': 'Libero',
          'elternname': 'Familie Felix',
          'notfallTelefon': '+49 151 5555555',
          'medizinischeHinweise': 'Leichte Knieempfindlichkeit',
          'scorecard': {
            'technik': 61,
            'taktik': 64,
            'fitness': 65,
            'mental': 78,
            'notizen':
                'Stark auf der Linie, am Offensivspiel mit dem Fuss arbeiten.',
            'letztesUpdate': '28.06.2026',
          },
        },
        {
          'name': 'Pascal Camara',
          'rolle': 'Trainer',
          'rueckennummer': null,
          'starkerFuss': '-',
          'hauptposition': 'Trainer',
          'nebenposition': 'Coaching',
          'elternname': '-',
          'notfallTelefon': '+49 171 9922110',
          'medizinischeHinweise': '-',
        },
        {
          'name': 'Kevin Glöckler',
          'rolle': 'Betreuer',
          'rueckennummer': null,
          'starkerFuss': '-',
          'hauptposition': 'Betreuung',
          'nebenposition': 'Organisation',
          'elternname': '-',
          'notfallTelefon': '+49 160 6666666',
          'medizinischeHinweise': '-',
        },
      ],
      'termine': [
        {
          'tag': 'Mo',
          'datum': '20.05',
          'zeit': '18:00',
          'event': 'Training - Sporthalle',
          'type': 'Training',
          'status': 'Offen',
          'updatedAt': 'Noch nicht aktualisiert',
          'reasonRequired': false,
          'abmeldeGrund': '',
          'treffpunkt': '17:45 Uhr Kabine 3',
          'ort': 'Sporthalle Bad Wildungen',
          'kleidung': 'Schwarzes Trainingsset, Schienbeinschoner Pflicht!',
          'notiz': 'Bitte pünktlich sein, wir starten direkt mit Taktik.',
          'teilnehmer': [
            {'name': 'Lian', 'status': 'Zusage', 'grund': ''},
            {'name': 'Mika', 'status': 'Zusage', 'grund': ''},
            {'name': 'Jonas', 'status': 'Absage', 'grund': 'Zahnarzttermin'},
            {
              'name': 'Felix',
              'status': 'Unsicher',
              'grund': 'Wartet auf Klausurergebnis',
            },
            {'name': 'Kian', 'status': 'Zusage', 'grund': ''},
          ],
        },
        {
          'tag': 'Di',
          'datum': '21.05',
          'zeit': '17:00',
          'event': 'Videoanalyse & Taktik',
          'type': 'Sonstiges',
          'status': 'Offen',
          'updatedAt': 'Noch nicht aktualisiert',
          'reasonRequired': false,
          'abmeldeGrund': '',
          'treffpunkt': '17:00 Uhr Jugendraum',
          'ort': 'Vereinsheim TV Friedrichstein',
          'kleidung': 'Freizeitkleidung',
          'notiz': 'Analyse des letzten Pokalspiels. Schreibzeug mitbringen.',
          'teilnehmer': [
            {'name': 'Lian', 'status': 'Zusage', 'grund': ''},
            {
              'name': 'Mika',
              'status': 'Absage',
              'grund': 'Keine Fahrgemeinschaft',
            },
            {'name': 'Jonas', 'status': 'Zusage', 'grund': ''},
          ],
        },
        {
          'tag': 'Mi',
          'datum': '22.05',
          'zeit': '19:00',
          'event': 'Freundschaftsspiel vs. Verein B',
          'type': 'Spiel',
          'status': 'Offen',
          'updatedAt': 'Noch nicht aktualisiert',
          'reasonRequired': true,
          'abmeldeGrund': '',
          'treffpunkt': '18:00 Uhr am Sportplatz',
          'ort': 'Kunstrasenplatz Friedrichstein',
          'kleidung': 'Rote Trikots (Heimset)',
          'notiz': 'Wichtiges Testspiel für die Startelf-Aufstellung.',
          'teilnehmer': [
            {'name': 'Lian', 'status': 'Zusage', 'grund': ''},
            {'name': 'Mika', 'status': 'Zusage', 'grund': ''},
          ],
        },
      ],
      'offeneStrafen': [
        {
          'spieler': 'Lian',
          'grund': 'Trikot vergessen',
          'status': 'offen',
          'betrag': 5.00,
          'icon': Icons.person,
          'offen': true,
          'bezahltVon': '',
        },
        {
          'spieler': 'Mika',
          'grund': 'Zuspätkommen Training',
          'status': 'offen',
          'betrag': 3.00,
          'icon': Icons.person,
          'offen': true,
          'bezahltVon': '',
        },
        {
          'spieler': 'Jonas',
          'grund': 'Wasserkästen für Spiel',
          'status': 'offen',
          'betrag': 12.50,
          'icon': Icons.person,
          'offen': true,
          'bezahltVon': '',
        },
      ],
      'kassenTransaktionen': [
        {
          'datum': '22.05.',
          'spieler': 'Lian',
          'grund': 'Zuspätkommen Training (10 Min)',
          'betrag': 2.00,
          'typ': 'Einnahme',
        },
        {
          'datum': '20.05.',
          'spieler': 'Mika',
          'grund': 'Trikot in Kabine vergessen',
          'betrag': 5.00,
          'typ': 'Einnahme',
        },
        {
          'datum': '18.05.',
          'spieler': 'Kevin Glöckler',
          'grund': 'Wasserkästen für Testspiel',
          'betrag': -12.50,
          'typ': 'Ausgabe',
        },
        {
          'datum': '10.05.',
          'spieler': 'Jonas',
          'grund': 'Schienbeinschoner vergessen',
          'betrag': 5.00,
          'typ': 'Einnahme',
        },
      ],
      'statistiken': [
        {
          'name': 'Lian',
          'spiele': 18,
          'tore': 14,
          'vorlagen': 8,
          'trainingsbeteiligung': 95,
        },
        {
          'name': 'Mika',
          'spiele': 17,
          'tore': 4,
          'vorlagen': 11,
          'trainingsbeteiligung': 88,
        },
        {
          'name': 'Kian',
          'spiele': 15,
          'tore': 6,
          'vorlagen': 3,
          'trainingsbeteiligung': 82,
        },
        {
          'name': 'Jonas',
          'spiele': 18,
          'tore': 1,
          'vorlagen': 2,
          'trainingsbeteiligung': 90,
        },
        {
          'name': 'Felix',
          'spiele': 12,
          'tore': 0,
          'vorlagen': 1,
          'trainingsbeteiligung': 65,
        },
      ],
      'strafenKatalog': [
        {
          'regel': 'Unentschuldigtes Fehlen beim Spiel',
          'strafe': 10.00,
          'icon': Icons.sports_soccer,
        },
        {
          'regel': 'Unentschuldigtes Fehlen beim Training',
          'strafe': 5.00,
          'icon': Icons.directions_run,
        },
        {
          'regel': 'Zuspätkommen (pro angefangene 5 Min)',
          'strafe': 1.00,
          'icon': Icons.timer,
        },
        {
          'regel': 'Arbeitsmaterial (Schienbeinschoner/Trikot) vergessen',
          'strafe': 5.00,
          'icon': Icons.checkroom,
        },
        {
          'regel': 'Gelbe Karte wegen Meckern',
          'strafe': 5.00,
          'icon': Icons.style,
        },
        {
          'regel': 'Rote Karte (Unsportlichkeit)',
          'strafe': 20.00,
          'icon': Icons.style,
        },
      ],
      'kartenUebersicht': [
        {'name': 'Lian', 'gelb': 3, 'rot': 0, 'sperre': 0},
        {'name': 'Mika', 'gelb': 5, 'rot': 1, 'sperre': 1},
        {'name': 'Kian', 'gelb': 2, 'rot': 0, 'sperre': 0},
        {'name': 'Jonas', 'gelb': 1, 'rot': 0, 'sperre': 0},
        {'name': 'Felix', 'gelb': 4, 'rot': 0, 'sperre': 0},
      ],
    },
    {
      'id': 'b_jugend',
      'name': 'B-Jugend Mannschaft',
      'photoCaption': 'B-Jugend Saison 2026',
      'photoColor': const Color(0xFF14532D),
      'photoBytes': null,
      'fussballDeTeamId': 'tv-friedrichstein-b-jugend',
      'vorbereitungsPlan': null,
      'vorbereitungsDateien': <Map<String, dynamic>>[],
      'termine': <Map<String, dynamic>>[],
      'offeneStrafen': <Map<String, dynamic>>[],
      'kassenTransaktionen': <Map<String, dynamic>>[],
      'statistiken': <Map<String, dynamic>>[],
      'strafenKatalog': <Map<String, dynamic>>[],
      'kartenUebersicht': <Map<String, dynamic>>[],
    },
  ];

  final TextEditingController _chatInputController = TextEditingController();
  final TextEditingController _whatsAppBroadcastController =
      TextEditingController();

  @override
  void dispose() {
    _chatInputController.dispose();
    _whatsAppBroadcastController.dispose();
    _hauptuebung1Controller.dispose();
    _hauptuebung2Controller.dispose();
    super.dispose();
  }

  Color _vereinsWappenColor = kPrimaryColor;
  Uint8List? _vereinsWappenBytes;

  final Map<int, bool> _expandedTermine = {};
  Map<String, dynamic>? _selectedTeamCache;
  String? _selectedTeamCacheId;

  Map<String, dynamic> get _selectedTeam {
    if (_selectedTeamCache != null &&
        _selectedTeamCacheId == _selectedTeamId &&
        _vereinsTeams.contains(_selectedTeamCache)) {
      return _selectedTeamCache!;
    }

    for (final team in _vereinsTeams) {
      if ((team['id'] as String?) == _selectedTeamId) {
        _selectedTeamCache = team;
        _selectedTeamCacheId = _selectedTeamId;
        return team;
      }
    }
    if (_vereinsTeams.isNotEmpty) {
      _selectedTeamCache = _vereinsTeams.first;
      _selectedTeamCacheId =
          (_vereinsTeams.first['id'] as String?) ?? _selectedTeamId;
      return _vereinsTeams.first;
    }
    return <String, dynamic>{
      'id': '',
      'name': 'Mannschaft',
      'termine': <Map<String, dynamic>>[],
      'offeneStrafen': <Map<String, dynamic>>[],
      'kassenTransaktionen': <Map<String, dynamic>>[],
      'statistiken': <Map<String, dynamic>>[],
      'strafenKatalog': <Map<String, dynamic>>[],
      'kartenUebersicht': <Map<String, dynamic>>[],
      'vorbereitungsDateien': <Map<String, dynamic>>[],
    };
  }

  List<Map<String, dynamic>> get _allTermine =>
      (_selectedTeam['termine'] as List).cast<Map<String, dynamic>>();
  List<Map<String, dynamic>> get _offeneStrafen =>
      (_selectedTeam['offeneStrafen'] as List).cast<Map<String, dynamic>>();
  List<Map<String, dynamic>> get _kassenTransaktionen =>
      (_selectedTeam['kassenTransaktionen'] as List)
          .cast<Map<String, dynamic>>();
  List<Map<String, dynamic>> get _spielerStatistiken =>
      (_selectedTeam['statistiken'] as List).cast<Map<String, dynamic>>();
  List<Map<String, dynamic>> get _strafenKatalog =>
      (_selectedTeam['strafenKatalog'] as List).cast<Map<String, dynamic>>();
  List<Map<String, dynamic>> get _kartenUebersicht =>
      (_selectedTeam['kartenUebersicht'] as List).cast<Map<String, dynamic>>();
  List<Map<String, dynamic>> get _teamMitglieder =>
      (_selectedTeam['mitglieder'] as List?)?.cast<Map<String, dynamic>>() ??
      <Map<String, dynamic>>[];
  Map<String, dynamic>? get _vorbereitungsPlan =>
      _selectedTeam['vorbereitungsPlan'] as Map<String, dynamic>?;
  List<Map<String, dynamic>> get _vorbereitungsDateien =>
      (_selectedTeam['vorbereitungsDateien'] as List?)
          ?.cast<Map<String, dynamic>>() ??
      <Map<String, dynamic>>[];

  String get _selectedTeamName =>
      (_selectedTeam['name'] as String?) ?? 'Mannschaft';

  String get _selectedFussballDeTeamId =>
      (_selectedTeam['fussballDeTeamId'] as String?) ??
      'tv-friedrichstein-c-jugend';

  Map<String, dynamic>? get _currentMemberProfile {
    for (final member in _vereinsMitglieder) {
      if ((member['name'] as String?) == _currentUserName) {
        return member;
      }
    }
    return null;
  }

  List<String> get _currentUserRoles {
    final profile = _currentMemberProfile;
    if (profile == null) {
      return <String>[_currentUserRole];
    }

    final rawRoles =
        (profile['rollen'] as List?)
            ?.map((role) => role.toString())
            .where((role) => role.trim().isNotEmpty)
            .toList() ??
        <String>[];
    if (rawRoles.isNotEmpty) return rawRoles;

    final singleRole = profile['rolle']?.toString().trim() ?? '';
    return singleRole.isEmpty
        ? <String>[_currentUserRole]
        : <String>[singleRole];
  }

  bool _hasAnyRole(Iterable<String> roles) {
    final activeRoles = _currentUserRoles.toSet();
    return roles.any(activeRoles.contains);
  }

  bool _hasRole(String role) => _currentUserRoles.contains(role);

  List<Map<String, dynamic>> get _visibleTeamsForCurrentUser {
    if (_hasRole('Vereinsadministrator')) {
      return List<Map<String, dynamic>>.from(_vereinsTeams);
    }

    final member = _currentMemberProfile;
    if (member == null) return <Map<String, dynamic>>[];

    final allowedRaw = (member['erlaubteTeams'] as List?) ?? <dynamic>[];
    final allowedIds = allowedRaw.map((e) => e.toString()).toSet();

    return _vereinsTeams
        .where((team) => allowedIds.contains(team['id']))
        .toList();
  }

  List<String> get _visibleTeamIdsForCurrentUser =>
      _visibleTeamsForCurrentUser.map((team) => team['id'] as String).toList();

  List<String> get _mitgliedNamen =>
      _vereinsMitglieder.map((member) => member['name'] as String).toList();

  void _syncRoleFromCurrentUserProfile() {
    final profile = _currentMemberProfile;
    if (profile == null) return;
    final roles = _currentUserRoles;
    _currentUserRole = roles.isNotEmpty
        ? roles.first
        : (profile['rolle'] as String?) ?? _currentUserRole;
  }

  void _ensureSelectedTeamAccess() {
    bool changed = false;
    final visibleIds = _visibleTeamIdsForCurrentUser;
    if (visibleIds.isEmpty) return;
    if (!visibleIds.contains(_selectedTeamId)) {
      _selectedTeamId = visibleIds.first;
      changed = true;
      _expandedTermine.clear();
      _terminCalendarSelectedDay = null;
      _terminCalendarFocusedDay = DateTime.now();
      _currentTeamSubView = 'uebersicht';
      _currentTerminSubView = 'list';
    }
    if (changed) {
      unawaited(_persistSelectedTeamForCurrentUser());
    }
  }

  Future<Map<String, String>> _loadLastTeamByUserMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLastTeamByUserKey);
    if (raw == null || raw.isEmpty) return <String, String>{};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, String>{};
      return decoded.map<String, String>((key, value) {
        return MapEntry(key.toString(), value.toString());
      });
    } catch (_) {
      return <String, String>{};
    }
  }

  Future<void> _saveLastTeamByUserMap(Map<String, String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastTeamByUserKey, jsonEncode(value));
  }

  Future<void> _persistSelectedTeamForCurrentUser() async {
    if (_currentUserName.trim().isEmpty || _selectedTeamId.trim().isEmpty) {
      return;
    }
    final map = await _loadLastTeamByUserMap();
    map[_currentUserName] = _selectedTeamId;
    await _saveLastTeamByUserMap(map);
  }

  Future<void> _restoreLastSelectedTeamForCurrentUser() async {
    final map = await _loadLastTeamByUserMap();
    final savedTeamId = map[_currentUserName];
    if (!mounted) return;

    setState(() {
      final visibleIds = _visibleTeamIdsForCurrentUser;
      if (savedTeamId != null && visibleIds.contains(savedTeamId)) {
        _selectedTeamId = savedTeamId;
      }
      _ensureSelectedTeamAccess();
    });
  }

  String get _teamPhotoCaption =>
      (_selectedTeam['photoCaption'] as String?) ?? 'Mannschaft';
  set _teamPhotoCaption(String value) {
    _selectedTeam['photoCaption'] = value;
  }

  Color get _teamPhotoColor =>
      (_selectedTeam['photoColor'] as Color?) ?? const Color(0xFF2563EB);
  set _teamPhotoColor(Color value) {
    _selectedTeam['photoColor'] = value;
  }

  Uint8List? get _teamPhotoBytes => _selectedTeam['photoBytes'] as Uint8List?;
  set _teamPhotoBytes(Uint8List? value) {
    _selectedTeam['photoBytes'] = value;
  }

  bool get _isCoachOrAdmin {
    return _hasAnyRole(const [
      'Vereinsadministrator',
      'Trainer',
      'Co-Trainer',
      'Betreuer',
    ]);
  }

  bool get _canManageVorbereitung {
    return _hasAnyRole(const ['Vereinsadministrator', 'Trainer']);
  }

  bool get _isVereinsAdmin {
    return _hasAnyRole(const ['Vereinsadministrator']);
  }

  bool get _canApproveAccounts {
    return _hasAnyRole(const ['Vereinsadministrator', 'Trainer']);
  }

  bool get _isSpielerRole {
    return _hasAnyRole(const ['Spieler']);
  }

  String _hashPassword(String raw) {
    final input = 'clubapp::salt::${raw.trim()}';
    return sha256.convert(utf8.encode(input)).toString();
  }

  String _generateTempPassword({int length = 10}) {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#%';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  int _allocateMemberId() {
    int maxId = 9999;
    for (final member in _vereinsMitglieder) {
      final parsed = int.tryParse(member['id']?.toString() ?? '');
      if (parsed != null && parsed > maxId) {
        maxId = parsed;
      }
    }
    return maxId + 1;
  }

  String tr(String key) {
    return AppI18n.of(context).t(key);
  }

  String _formatEuro(double value) {
    return '${value.toStringAsFixed(2).replaceAll('.', ',')} €';
  }

  String _formatTodayForList() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
  }

  String _normalizeTeamId(String rawName) {
    final lower = rawName.toLowerCase().trim();
    final sanitized = lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return sanitized.isEmpty ? 'team' : sanitized;
  }

  String _uniqueTeamIdForName(String teamName) {
    final baseId = _normalizeTeamId(teamName);
    var candidate = baseId;
    int suffix = 2;
    final existingIds = _vereinsTeams
        .map((t) => (t['id'] as String?) ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    while (existingIds.contains(candidate)) {
      candidate = '${baseId}_$suffix';
      suffix++;
    }
    return candidate;
  }

  Map<String, dynamic> _buildNewTeamFromName(String teamName) {
    final trimmedName = teamName.trim();
    final newTeamId = _uniqueTeamIdForName(trimmedName);
    return {
      'id': newTeamId,
      'name': trimmedName,
      'saison': _dfbnetImportSaison,
      'spielerIds': <String>[],
      'photoCaption': '$trimmedName Saison ${DateTime.now().year}',
      'photoColor': const Color(0xFF2563EB),
      'photoBytes': null,
      'fussballDeTeamId': newTeamId,
      'vorbereitungsPlan': null,
      'vorbereitungsDateien': <Map<String, dynamic>>[],
      'mitglieder': <Map<String, dynamic>>[],
      'termine': <Map<String, dynamic>>[],
      'offeneStrafen': <Map<String, dynamic>>[],
      'kassenTransaktionen': <Map<String, dynamic>>[],
      'statistiken': <Map<String, dynamic>>[],
      'strafenKatalog': <Map<String, dynamic>>[],
      'kartenUebersicht': <Map<String, dynamic>>[],
    };
  }

  String _normalizePassNummer(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toUpperCase();
  }

  List<String> _splitCsvLine(String line, String delimiter) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
          continue;
        }
        inQuotes = !inQuotes;
        continue;
      }
      if (!inQuotes && char == delimiter) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    result.add(buffer.toString().trim());
    return result;
  }

  String _normalizeCsvHeader(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  bool _isLikelyDfbnetHeader(List<String> columns) {
    final normalized = columns.map(_normalizeCsvHeader).toSet();
    const headerHints = {
      'nachname',
      'familienname',
      'vorname',
      'geburtsdatum',
      'geburtstag',
      'passnummer',
      'spielerpassnummer',
      'passnr',
    };

    return normalized.any((entry) {
      for (final hint in headerHints) {
        if (entry == hint || entry.contains(hint) || hint.contains(entry)) {
          return true;
        }
      }
      return false;
    });
  }

  Map<String, int> _resolveDfbnetColumnMap(List<String> headerColumns) {
    final indexByHeader = <String, int>{};
    for (int i = 0; i < headerColumns.length; i++) {
      indexByHeader[_normalizeCsvHeader(headerColumns[i])] = i;
    }

    int pickIndex(List<String> aliases, int fallback) {
      for (final alias in aliases) {
        final normalizedAlias = _normalizeCsvHeader(alias);
        if (indexByHeader.containsKey(normalizedAlias)) {
          return indexByHeader[normalizedAlias]!;
        }
      }

      for (final entry in indexByHeader.entries) {
        for (final alias in aliases) {
          final normalizedAlias = _normalizeCsvHeader(alias);
          if (entry.key.contains(normalizedAlias) ||
              normalizedAlias.contains(entry.key)) {
            return entry.value;
          }
        }
      }

      return fallback;
    }

    return {
      'nachname': pickIndex(['nachname', 'familienname', 'lastname'], 0),
      'vorname': pickIndex(['vorname', 'firstname', 'rufname'], 1),
      'geburtsdatum': pickIndex([
        'geburtsdatum',
        'geburtstag',
        'dob',
        'birthdate',
      ], 2),
      'passNummer': pickIndex([
        'passnummer',
        'spielerpassnummer',
        'spielerpass',
        'passnr',
        'passid',
      ], 3),
    };
  }

  String _csvValueAt(List<String> columns, int index) {
    if (index < 0 || index >= columns.length) return '';
    return columns[index].trim();
  }

  Map<String, dynamic> _parseDfbnetCsvPreview(String csvInhalt) {
    final zeilen = csvInhalt
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n');
    if (zeilen.isEmpty) {
      return {
        'rows': <Map<String, String>>[],
        'totalRows': 0,
        'validRows': 0,
        'skippedRows': 0,
      };
    }

    final firstLine = zeilen.first.replaceAll('\uFEFF', '');
    final delimiter = firstLine.split(';').length >= firstLine.split(',').length
        ? ';'
        : ',';
    final firstColumns = _splitCsvLine(firstLine, delimiter);
    final hasHeader = _isLikelyDfbnetHeader(firstColumns);
    final columnMap = hasHeader
        ? _resolveDfbnetColumnMap(firstColumns)
        : {'nachname': 0, 'vorname': 1, 'geburtsdatum': 2, 'passNummer': 3};

    final startIndex = hasHeader ? 1 : 0;
    int validRows = 0;
    int skippedRows = 0;
    final previewRows = <Map<String, String>>[];

    for (int i = startIndex; i < zeilen.length; i++) {
      final raw = zeilen[i].trim();
      if (raw.isEmpty) continue;
      final spalten = _splitCsvLine(raw, delimiter);
      final nachname = _csvValueAt(spalten, columnMap['nachname'] ?? 0);
      final vorname = _csvValueAt(spalten, columnMap['vorname'] ?? 1);
      final geburtsdatum = _csvValueAt(spalten, columnMap['geburtsdatum'] ?? 2);
      final pass = _normalizePassNummer(
        _csvValueAt(spalten, columnMap['passNummer'] ?? 3),
      );

      if (pass.isEmpty) {
        skippedRows++;
        continue;
      }

      validRows++;
      if (previewRows.length < 10) {
        previewRows.add({
          'name': '$vorname $nachname'.trim(),
          'geburtsdatum': geburtsdatum,
          'passNummer': pass,
        });
      }
    }

    return {
      'rows': previewRows,
      'totalRows': validRows + skippedRows,
      'validRows': validRows,
      'skippedRows': skippedRows,
      'hasHeader': hasHeader,
      'delimiter': delimiter,
    };
  }

  Map<String, dynamic> importiereDFBnetKader(
    String csvInhalt,
    String mannschaftsName,
  ) {
    final zeilen = csvInhalt
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n');
    if (zeilen.isEmpty) {
      return {'importiert': 0, 'zugewiesen': 0, 'mannschaft': mannschaftsName};
    }

    final firstLine = zeilen.first.replaceAll('\uFEFF', '');
    final delimiter = firstLine.split(';').length >= firstLine.split(',').length
        ? ';'
        : ',';
    final firstColumns = _splitCsvLine(firstLine, delimiter);
    final hasHeader = _isLikelyDfbnetHeader(firstColumns);
    final columnMap = hasHeader
        ? _resolveDfbnetColumnMap(firstColumns)
        : {'nachname': 0, 'vorname': 1, 'geburtsdatum': 2, 'passNummer': 3};

    int importedCount = 0;
    int assignedCount = 0;
    int skippedCount = 0;

    setState(() {
      Map<String, dynamic>? zielTeam;
      for (final team in _vereinsTeams) {
        final teamName = (team['name'] as String?)?.trim().toLowerCase() ?? '';
        if (teamName == mannschaftsName.trim().toLowerCase()) {
          zielTeam = team;
          break;
        }
      }

      zielTeam ??= _buildNewTeamFromName(mannschaftsName)
        ..['saison'] = _dfbnetImportSaison;
      if (!_vereinsTeams.contains(zielTeam)) {
        _vereinsTeams.add(zielTeam);
      }

      final teamRef = zielTeam;

      final String teamId =
          (teamRef['id'] as String?) ?? _normalizeTeamId(mannschaftsName);
      final String teamName = (teamRef['name'] as String?) ?? mannschaftsName;
      final List<Map<String, dynamic>> teamMembers =
          ((teamRef['mitglieder'] as List?) ?? <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .toList();

      final Set<String> teamPlayerIds =
          (((teamRef['spielerIds'] as List?) ?? <dynamic>[])
                  .map((e) => e.toString())
                  .where((e) => e.trim().isNotEmpty))
              .toSet();

      final startIndex = hasHeader ? 1 : 0;
      for (int i = startIndex; i < zeilen.length; i++) {
        final zeile = zeilen[i].trim();
        if (zeile.isEmpty) continue;

        final spalten = _splitCsvLine(zeile, delimiter);
        final nachname = _csvValueAt(spalten, columnMap['nachname'] ?? 0);
        final vorname = _csvValueAt(spalten, columnMap['vorname'] ?? 1);
        final geburtsdatum = _csvValueAt(
          spalten,
          columnMap['geburtsdatum'] ?? 2,
        );
        final passNummerRaw = _csvValueAt(
          spalten,
          columnMap['passNummer'] ?? 3,
        );
        final passNummer = _normalizePassNummer(passNummerRaw);
        if (passNummer.isEmpty) {
          skippedCount++;
          continue;
        }

        final fullName = '$vorname $nachname'.trim();
        final startSecret = passNummer.length >= 4
            ? passNummer.substring(0, 4)
            : passNummer;

        final existingIndex = _vereinsMitglieder.indexWhere(
          (m) =>
              _normalizePassNummer(m['passNummer']?.toString() ?? '') ==
              passNummer,
        );

        Map<String, dynamic> spieler;
        if (existingIndex < 0) {
          final int newId = _allocateMemberId();
          spieler = {
            'id': newId,
            'name': fullName.isEmpty ? 'Spieler $passNummer' : fullName,
            'vorname': vorname,
            'nachname': nachname,
            'geburtsdatum': geburtsdatum,
            'passNummer': passNummer,
            'rolle': 'Spieler',
            'rollen': ['Spieler'],
            'kontakt': 'DFBnet Import',
            'email': 'dfbnet_$passNummer@verein.local',
            'phone': '-',
            'notfallTelefon': '-',
            'mannschaften': [teamName],
            'erlaubteTeams': [teamId],
            'mustChangePassword': true,
            'passwort': 'Start$startSecret!',
            'passwordHash': _hashPassword('Start$startSecret!'),
            'scorecard': {
              'technik': 50,
              'taktik': 50,
              'fitness': 50,
              'mental': 50,
              'notizen': '',
              'letztesUpdate': _formatTodayForList(),
            },
          };
          _vereinsMitglieder.add(spieler);
          importedCount++;
        } else {
          spieler = _vereinsMitglieder[existingIndex];
        }

        final teamAssignments =
            ((spieler['mannschaften'] as List?) ?? <dynamic>[])
                .map((e) => e.toString())
                .toSet();
        if (!teamAssignments.contains(teamName)) {
          teamAssignments.add(teamName);
          spieler['mannschaften'] = teamAssignments.toList();
        }

        final allowedTeams =
            ((spieler['erlaubteTeams'] as List?) ?? <dynamic>[])
                .map((e) => e.toString())
                .toSet();
        if (!allowedTeams.contains('all') && !allowedTeams.contains(teamId)) {
          allowedTeams.add(teamId);
          spieler['erlaubteTeams'] = allowedTeams.toList();
        }

        final alreadyInTeam = teamMembers.any(
          (m) =>
              (m['passNummer']?.toString() ?? '').toUpperCase() == passNummer,
        );
        if (!alreadyInTeam) {
          teamMembers.add({
            'id': spieler['id'],
            'name': spieler['name'],
            'vorname': vorname,
            'nachname': nachname,
            'geburtsdatum': geburtsdatum,
            'passNummer': passNummer,
            'rolle': 'Spieler',
            'rueckennummer': null,
            'starkerFuss': '-',
            'hauptposition': 'Spieler',
            'nebenposition': '-',
            'elternname': '-',
            'notfallTelefon': '-',
            'medizinischeHinweise': '-',
            'scorecard': {
              'technik': 50,
              'taktik': 50,
              'fitness': 50,
              'mental': 50,
              'notizen': '',
              'letztesUpdate': _formatTodayForList(),
            },
          });
          assignedCount++;
        }

        if (spieler['id'] != null) {
          teamPlayerIds.add(spieler['id'].toString());
        }
      }

      teamRef['mitglieder'] = teamMembers;
      teamRef['spielerIds'] = teamPlayerIds.toList();
      teamRef['saison'] = _dfbnetImportSaison;
      _dfbnetImportResultSuccess = true;
      _dfbnetImportResultMessage =
          'Erfolgreich $importedCount Spieler importiert und $assignedCount Spieler der Mannschaft $teamName zugewiesen.${skippedCount > 0 ? ' $skippedCount Zeilen wurden wegen fehlender Passnummer uebersprungen.' : ''}';
      _selectedTeamId = teamId;
    });

    return {
      'importiert': importedCount,
      'zugewiesen': assignedCount,
      'mannschaft': mannschaftsName,
    };
  }

  Future<void> _showAddTeamDialog() async {
    if (_currentUserRole != 'Vereinsadministrator') return;

    final nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: const Text(
          'Neue Mannschaft anlegen',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: SizedBox(
          width: adaptiveDialogWidth(context),
          child: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Mannschaftsname',
              hintText: 'z.B. A-Jugend oder 1. Mannschaft',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final newTeam = _buildNewTeamFromName(name);
              setState(() {
                _vereinsTeams.add(newTeam);
                _selectedTeamId = newTeam['id'] as String;
                _expandedTermine.clear();
                _terminCalendarSelectedDay = null;
                _terminCalendarFocusedDay = DateTime.now();
                _currentTeamSubView = 'uebersicht';
                _currentTerminSubView = 'list';
              });
              unawaited(_persistSelectedTeamForCurrentUser());
              Navigator.pop(context);
            },
            child: const Text('Anlegen'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameTeamDialog(Map<String, dynamic> team) async {
    if (_currentUserRole != 'Vereinsadministrator') return;

    final nameController = TextEditingController(
      text: (team['name'] as String?) ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: const Text(
          'Mannschaft umbenennen',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: SizedBox(
          width: adaptiveDialogWidth(context),
          child: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Neuer Mannschaftsname',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;
              setState(() {
                team['name'] = newName;
                team['photoCaption'] = '$newName Saison ${DateTime.now().year}';
              });
              Navigator.pop(context);
            },
            child: Text(tr('save')),
          ),
        ],
      ),
    );
  }

  void _deleteTeamById(String teamId) {
    if (_currentUserRole != 'Vereinsadministrator') return;
    if (_vereinsTeams.length <= 1) return;

    setState(() {
      _vereinsTeams.removeWhere((team) => team['id'] == teamId);
      for (final member in _vereinsMitglieder) {
        final assigned =
            (member['erlaubteTeams'] as List?)?.cast<dynamic>() ?? <dynamic>[];
        if (assigned.contains('all')) continue;
        assigned.removeWhere((id) => id.toString() == teamId);
        member['erlaubteTeams'] = assigned.map((e) => e.toString()).toList();
      }

      final stillExists = _vereinsTeams.any(
        (team) => team['id'] == _selectedTeamId,
      );
      if (!stillExists && _vereinsTeams.isNotEmpty) {
        _selectedTeamId = _vereinsTeams.first['id'] as String;
      }

      _expandedTermine.clear();
      _terminCalendarSelectedDay = null;
      _terminCalendarFocusedDay = DateTime.now();
      _currentTeamSubView = 'uebersicht';
      _currentTerminSubView = 'list';
    });
    unawaited(_persistSelectedTeamForCurrentUser());
    if (widget.onAuthDataChanged != null) {
      unawaited(widget.onAuthDataChanged!.call());
    }
  }

  Future<bool> _showDeleteTeamConfirmDialog(Map<String, dynamic> team) async {
    final teamName = (team['name'] as String?) ?? 'Mannschaft';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: const Text(
          'Mannschaft loeschen?',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: SizedBox(
          width: adaptiveDialogWidth(context),
          child: Text(
            'Moechtest du die Mannschaft "$teamName" wirklich loeschen? Diese Aktion kann nicht rueckgaengig gemacht werden.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Loeschen'),
          ),
        ],
      ),
    );

    return confirmed == true;
  }

  Future<void> _showManageTeamsDialog() async {
    if (_currentUserRole != 'Vereinsadministrator') return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: kCardColor,
          title: const Text(
            'Mannschaften verwalten',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          content: SizedBox(
            width: adaptiveDialogWidth(context),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _vereinsTeams.map((team) {
                  final id = team['id'] as String;
                  final name = (team['name'] as String?) ?? id;
                  final isSelected = id == _selectedTeamId;
                  final canDelete = _vereinsTeams.length > 1;

                  return Card(
                    color: kDarkBackground,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(
                        isSelected ? Icons.radio_button_checked : Icons.groups,
                        color: isSelected ? kPrimaryColor : Colors.grey,
                      ),
                      title: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'ID: $id',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Umbenennen',
                            onPressed: () async {
                              await _showRenameTeamDialog(team);
                              if (!context.mounted) return;
                              setDialogState(() {});
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                          ),
                          IconButton(
                            tooltip: canDelete
                                ? 'Mannschaft loeschen'
                                : 'Mindestens ein Team muss bestehen bleiben',
                            onPressed: canDelete
                                ? () async {
                                    final confirmed =
                                        await _showDeleteTeamConfirmDialog(
                                          team,
                                        );
                                    if (!mounted || !confirmed) return;
                                    _deleteTeamById(id);
                                    setDialogState(() {});
                                  }
                                : null,
                            icon: Icon(
                              Icons.delete,
                              color: canDelete ? Colors.redAccent : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('close')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAssignMemberTeamsDialog() async {
    if (_currentUserRole != 'Vereinsadministrator') return;

    String selectedMemberName = _mitgliedNamen.first;
    Set<String> selectedTeamIds = {};

    void syncFromMemberName(String name) {
      final member = _vereinsMitglieder.firstWhere(
        (m) => (m['name'] as String?) == name,
        orElse: () => <String, dynamic>{},
      );
      final raw = (member['erlaubteTeams'] as List?) ?? <dynamic>[];
      selectedTeamIds = raw.map((e) => e.toString()).toSet();
    }

    syncFromMemberName(selectedMemberName);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: kCardColor,
          title: const Text(
            'Spieler einem Team zuweisen',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          content: SizedBox(
            width: adaptiveDialogWidth(context),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedMemberName,
                    decoration: const InputDecoration(labelText: 'Mitglied'),
                    dropdownColor: kCardColor,
                    items: _mitgliedNamen
                        .map(
                          (name) => DropdownMenuItem<String>(
                            value: name,
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedMemberName = value;
                        syncFromMemberName(value);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  ..._vereinsTeams.map((team) {
                    final teamId = team['id'] as String;
                    final teamName = (team['name'] as String?) ?? teamId;
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: selectedTeamIds.contains(teamId),
                      title: Text(
                        teamName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'ID: $teamId',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            selectedTeamIds.add(teamId);
                          } else {
                            selectedTeamIds.remove(teamId);
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () {
                final target = _vereinsMitglieder.firstWhere(
                  (m) => (m['name'] as String?) == selectedMemberName,
                  orElse: () => <String, dynamic>{},
                );
                if (target.isEmpty) {
                  Navigator.pop(context);
                  return;
                }

                setState(() {
                  final isAdmin =
                      (target['rolle'] as String?) == 'Vereinsadministrator';
                  target['erlaubteTeams'] = isAdmin
                      ? <String>['all']
                      : selectedTeamIds.toList();
                  _ensureSelectedTeamAccess();
                });
                if (widget.onAuthDataChanged != null) {
                  unawaited(widget.onAuthDataChanged!.call());
                }
                Navigator.pop(context);
              },
              child: Text(tr('save')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveWaitingAccount({
    required Map<String, dynamic> konto,
    required List<String> rollen,
    required List<String> teamIds,
  }) async {
    final contact = (konto['email'] as String?)?.trim().toLowerCase() ?? '';
    final fullName = (konto['name'] as String?)?.trim() ?? 'Unbekannt';
    final passwordHash = (konto['passwordHash'] as String?)?.trim() ?? '';
    if (contact.isEmpty || passwordHash.isEmpty) return;

    setState(() {
      _wartendeKonten.remove(konto);
      _vereinsMitglieder.add({
        'id':
            int.tryParse(konto['id']?.toString() ?? '') ?? _allocateMemberId(),
        'name': fullName,
        'rolle': rollen.isNotEmpty ? rollen.first : 'Spieler',
        'rollen': rollen,
        'email': contact,
        'kontakt': contact,
        'phone': '-',
        'erlaubteTeams': teamIds,
        'passwort': '',
        'passwordHash': passwordHash,
        'mustChangePassword': konto['mustChangePassword'] == true,
      });
      _freigabeAuditLog.insert(0, {
        'timestamp': DateTime.now().toIso8601String(),
        'approvedBy': _currentUserName,
        'approvedByRole': _currentUserRole,
        'accountName': fullName,
        'accountEmail': contact,
        'assignedRoles': rollen,
        'assignedTeams': teamIds,
      });
    });

    if (widget.onAuthDataChanged != null) {
      await widget.onAuthDataChanged!.call();
    }
  }

  Widget _buildAdminCreateUserScreen() {
    if (!_isCoachOrAdmin) {
      return _buildRechteGesperrtSeite(
        'Nur Trainer, Betreuer und Vereinsadministratoren duerfen neue Profile anlegen.',
      );
    }

    const rollen = [
      'Spieler',
      'Betreuer',
      'Co-Trainer',
      'Trainer',
      'Vereinsadministrator',
    ];

    final selectedRoles = <String>{'Spieler'};
    final selectedTeamIds = <String>{};
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setLocalState) {
        void fillGeneratedPassword() {
          setLocalState(() {
            passwordController.text = _generateTempPassword();
          });
        }

        Future<void> copyTempPassword() async {
          final value = passwordController.text.trim();
          if (value.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Bitte zuerst ein temporäres Passwort eingeben oder generieren.',
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
          await Clipboard.setData(ClipboardData(text: value));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Temporäres Passwort in die Zwischenablage kopiert.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }

        Future<void> submit() async {
          final name = nameController.text.trim();
          final email = emailController.text.trim().toLowerCase();
          final tempPassword = passwordController.text.trim();

          if (name.isEmpty || email.isEmpty || tempPassword.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bitte alle Felder ausfuellen.'),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
          if (!email.contains('@')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bitte eine gueltige E-Mail-Adresse eingeben.'),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
          if (tempPassword.length < 6) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Das temporaere Passwort muss mindestens 6 Zeichen haben.',
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }

          final exists = _vereinsMitglieder.any(
            (m) =>
                ((m['email'] ?? m['kontakt'])?.toString().toLowerCase() ??
                    '') ==
                email,
          );
          if (exists) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Zu dieser E-Mail existiert bereits ein Konto.'),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }

          if (!selectedRoles.contains('Vereinsadministrator') &&
              selectedTeamIds.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bitte mindestens ein Team zuweisen.'),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }

          final normalizedRoles = rollen.where(selectedRoles.contains).toList();
          if (normalizedRoles.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bitte mindestens eine Rolle auswählen.'),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }

          final allowedTeams = normalizedRoles.contains('Vereinsadministrator')
              ? <String>['all']
              : selectedTeamIds.toList();

          setState(() {
            _vereinsMitglieder.add({
              'id': _allocateMemberId(),
              'name': name,
              'email': email,
              'kontakt': email,
              'rolle': normalizedRoles.first,
              'rollen': normalizedRoles,
              'phone': '-',
              'erlaubteTeams': allowedTeams,
              'passwort': tempPassword,
              'passwordHash': _hashPassword(tempPassword),
              'mustChangePassword': true,
            });
          });

          if (widget.onAuthDataChanged != null) {
            await widget.onAuthDataChanged!.call();
          }

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Profil wurde angelegt. Passwortwechsel beim ersten Login ist verpflichtend.',
              ),
              backgroundColor: Colors.green,
            ),
          );

          setLocalState(() {
            selectedRoles
              ..clear()
              ..add('Spieler');
            selectedTeamIds.clear();
            nameController.clear();
            emailController.clear();
            passwordController.clear();
          });
        }

        final showTeamAssignment = !selectedRoles.contains(
          'Vereinsadministrator',
        );

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Profil einpflegen',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lege ein neues Konto mit temporaerem Passwort an. Der Nutzer muss das Passwort beim ersten Login aendern.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 18),
            Card(
              color: kCardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Vollstaendiger Name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-Mail-Adresse / Benutzername',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rollen',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...rollen.map((role) {
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: selectedRoles.contains(role),
                        title: Text(role),
                        onChanged: (checked) {
                          setLocalState(() {
                            if (checked == true) {
                              selectedRoles.add(role);
                            } else {
                              selectedRoles.remove(role);
                            }
                            if (selectedRoles.contains(
                              'Vereinsadministrator',
                            )) {
                              selectedTeamIds.clear();
                            }
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Temporäres Start-Passwort',
                        suffixIcon: IconButton(
                          tooltip: 'Temporäres Passwort generieren',
                          onPressed: fillGeneratedPassword,
                          icon: const Icon(Icons.auto_fix_high),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          TextButton.icon(
                            onPressed: fillGeneratedPassword,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Temporäres Passwort generieren'),
                          ),
                          TextButton.icon(
                            onPressed: copyTempPassword,
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Passwort kopieren'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (showTeamAssignment) ...[
                      const Text(
                        'Teamzuweisung',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._vereinsTeams.map((team) {
                        final teamId = team['id'] as String;
                        final teamName = (team['name'] as String?) ?? teamId;
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: selectedTeamIds.contains(teamId),
                          title: Text(teamName),
                          subtitle: Text(
                            'ID: $teamId',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          onChanged: (checked) {
                            setLocalState(() {
                              if (checked == true) {
                                selectedTeamIds.add(teamId);
                              } else {
                                selectedTeamIds.remove(teamId);
                              }
                            });
                          },
                        );
                      }),
                    ] else
                      const Text(
                        'Vereinsadministratoren erhalten Zugriff auf alle Teams.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                        ),
                        onPressed: submit,
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Konto anlegen'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKontenFreigabeView() {
    if (!_canApproveAccounts) {
      return _buildRechteGesperrtSeite(
        'Nur Trainer und Vereinsadministratoren duerfen Konten freigeben.',
      );
    }

    const rollen = ['Spieler', 'Betreuer', 'Co-Trainer', 'Trainer'];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Konten verknuepfen / Freigeben',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Neue Registrierungen mit Rolle und Mannschaften freischalten.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 18),
        if (_wartendeKonten.isEmpty)
          const Card(
            color: kCardColor,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Aktuell sind keine wartenden Konten vorhanden.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ..._wartendeKonten.map((konto) {
            final selectedRoles = <String>{'Spieler'};
            final selectedTeamIds = <String>{};

            return StatefulBuilder(
              builder: (context, setCardState) {
                return Card(
                  color: kCardColor,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.white10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (konto['name'] as String?) ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (konto['email'] as String?) ?? '-',
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Rollen zuweisen',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...rollen.map((role) {
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(role),
                            value: selectedRoles.contains(role),
                            onChanged: (checked) {
                              setCardState(() {
                                if (checked == true) {
                                  selectedRoles.add(role);
                                } else {
                                  selectedRoles.remove(role);
                                }
                              });
                            },
                          );
                        }),
                        const SizedBox(height: 10),
                        const Text(
                          'Mannschaften zuordnen',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._vereinsTeams.map((team) {
                          final teamId = team['id'] as String;
                          final teamName = (team['name'] as String?) ?? teamId;
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              teamName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'ID: $teamId',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: selectedTeamIds.contains(teamId),
                            onChanged: (checked) {
                              setCardState(() {
                                if (checked == true) {
                                  selectedTeamIds.add(teamId);
                                } else {
                                  selectedTeamIds.remove(teamId);
                                }
                              });
                            },
                          );
                        }),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                            ),
                            onPressed:
                                selectedTeamIds.isEmpty || selectedRoles.isEmpty
                                ? null
                                : () => _approveWaitingAccount(
                                    konto: konto,
                                    rollen: selectedRoles.toList(),
                                    teamIds: selectedTeamIds.toList(),
                                  ),
                            icon: const Icon(Icons.verified_user),
                            label: const Text(
                              'Konto verknuepfen & Freischalten',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
      ],
    );
  }

  Widget _buildFreigabeAuditView() {
    if (!_canApproveAccounts) {
      return _buildRechteGesperrtSeite(
        'Nur Trainer und Vereinsadministratoren sehen das Freigabe-Protokoll.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Freigabe-Protokoll',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Historie aller Konto-Freigaben mit Rollen- und Teamzuordnung.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 18),
        if (_freigabeAuditLog.isEmpty)
          const Card(
            color: kCardColor,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Es liegen noch keine Freigaben vor.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ..._freigabeAuditLog.map((entry) {
            final tsRaw = (entry['timestamp'] as String?) ?? '';
            final dt = DateTime.tryParse(tsRaw);
            final tsText = dt == null
                ? tsRaw
                : '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            final teams = (entry['assignedTeams'] as List?) ?? <dynamic>[];
            final assignedRoles =
                (entry['assignedRoles'] as List?) ??
                (entry['assignedRole'] != null
                    ? <dynamic>[entry['assignedRole']]
                    : <dynamic>[]);

            return Card(
              color: kCardColor,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (entry['accountName'] as String?) ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (entry['accountEmail'] as String?) ?? '-',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rollen: ${assignedRoles.map((e) => e.toString()).join(', ')}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Teams: ${teams.map((e) => e.toString()).join(', ')}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Freigegeben von ${(entry['approvedBy'] as String?) ?? '-'} (${(entry['approvedByRole'] as String?) ?? '-'}) am $tsText',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  void _switchSelectedTeam(String newTeamId) {
    if (newTeamId == _selectedTeamId) return;
    if (!_visibleTeamIdsForCurrentUser.contains(newTeamId)) return;
    setState(() {
      _selectedTeamId = newTeamId;
      _expandedTermine.clear();
      _terminCalendarSelectedDay = null;
      _terminCalendarFocusedDay = DateTime.now();
      _currentTeamSubView = 'uebersicht';
      _currentTerminSubView = 'list';
    });
    unawaited(_persistSelectedTeamForCurrentUser());
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCardColor,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language, color: Colors.white),
                title: Text(tr('language')),
              ),
              ListTile(
                title: Text(tr('language_de')),
                onTap: () {
                  VereinsApp.setLocale(context, const Locale('de'));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(tr('language_en')),
                onTap: () {
                  VereinsApp.setLocale(context, const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(tr('language_tr')),
                onTap: () {
                  VereinsApp.setLocale(context, const Locale('tr'));
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleTerminStatusWechsel(int index, String neuerStatus) {
    final termin = _allTermine[index];
    if (termin['reasonRequired'] == true &&
        (neuerStatus == 'Absage' || neuerStatus == 'Unsicher')) {
      _zeigeGrundDialog(index, neuerStatus);
    } else {
      _updateTerminStatus(index, neuerStatus, '');
    }
  }

  void _updateTerminStatus(int index, String status, String grund) {
    setState(() {
      _allTermine[index]['status'] = status;
      _allTermine[index]['abmeldeGrund'] = grund;
      _allTermine[index]['updatedAt'] =
          '${DateTime.now().toString().substring(11, 16)} Uhr';

      final List<Map<String, String>> liste = List<Map<String, String>>.from(
        _allTermine[index]['teilnehmer'],
      );
      liste.removeWhere((element) => element['name'] == 'Du (Eigener Account)');
      liste.add({
        'name': 'Du (Eigener Account)',
        'status': status,
        'grund': grund,
      });
      _allTermine[index]['teilnehmer'] = liste;
    });
  }

  void _toggleReasonRequired(int index, bool value) {
    setState(() {
      _allTermine[index]['reasonRequired'] = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _vereinsMitglieder = widget.vereinsMitglieder;
    _wartendeKonten = widget.wartendeKonten;
    _freigabeAuditLog = widget.freigabeAuditLog;
    _currentUserName = widget.initialUserName;
    _syncRoleFromCurrentUserProfile();
    _ensureSelectedTeamAccess();
    unawaited(_restoreLastSelectedTeamForCurrentUser());
    _migrateLegacyTerminDates();
    _ensureDateObjInTermine();
    _ensureScorecardsInTeamMembers();
    _loadVereinsWappenSettings();
  }

  void _migrateLegacyTerminDates() {
    for (final team in _vereinsTeams) {
      final termine =
          (team['termine'] as List?)?.cast<Map<String, dynamic>>() ??
          <Map<String, dynamic>>[];
      for (final termin in termine) {
        final datum = termin['datum']?.toString() ?? '';
        final zeit = termin['zeit']?.toString() ?? '00:00';
        if (!_hasExplicitYearInDatum(datum)) {
          final parsed = _parseDateTime(datum, zeit);
          if (parsed != null) {
            termin['datum'] = _formatDatumForStorage(parsed);
          }
        }
      }
    }
  }

  Future<void> _loadVereinsWappenSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedColorValue = prefs.getInt(_kVereinsWappenColorKey);
    final savedImageBase64 = prefs.getString(_kVereinsWappenImageKey);

    Uint8List? decodedImage;
    if (savedImageBase64 != null && savedImageBase64.isNotEmpty) {
      try {
        decodedImage = base64Decode(savedImageBase64);
      } catch (_) {
        decodedImage = null;
      }
    }

    if (!mounted) return;

    setState(() {
      if (savedColorValue != null) {
        _vereinsWappenColor = Color(savedColorValue);
      }
      _vereinsWappenBytes = decodedImage;
    });
  }

  Future<void> _saveVereinsWappenSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kVereinsWappenColorKey, _vereinsWappenColor.toARGB32());

    if (_vereinsWappenBytes != null && _vereinsWappenBytes!.isNotEmpty) {
      await prefs.setString(
        _kVereinsWappenImageKey,
        base64Encode(_vereinsWappenBytes!),
      );
    } else {
      await prefs.remove(_kVereinsWappenImageKey);
    }
  }

  void _ensureDateObjInTermine() {
    for (final team in _vereinsTeams) {
      final termine =
          (team['termine'] as List?)?.cast<Map<String, dynamic>>() ??
          <Map<String, dynamic>>[];
      for (final termin in termine) {
        termin['dateObj'] = _parseTerminDateObj(termin);
        termin['tag'] = _computeWeekdayLabel(termin['dateObj'] as DateTime?);
      }
    }
  }

  DateTime? _parseTerminDateObj(Map<String, dynamic> termin) {
    final datum = termin['datum']?.toString() ?? '';
    final zeit = termin['zeit']?.toString() ?? '';
    return _parseDateTime(datum, zeit);
  }

  String _formatDatumForStorage(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  bool _hasExplicitYearInDatum(String datum) {
    final cleaned = datum.replaceAll(' ', '');
    final parts = cleaned.split('.').where((p) => p.isNotEmpty).toList();
    if (parts.length < 3) return false;
    return int.tryParse(parts[2]) != null;
  }

  DateTime? _parseDateOnly(String datum) {
    final now = DateTime.now();
    final cleaned = datum.replaceAll(' ', '');
    final parts = cleaned.split('.').where((p) => p.isNotEmpty).toList();
    if (parts.length < 2) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = parts.length >= 3 ? int.tryParse(parts[2]) : null;
    if (day == null || month == null) return null;

    try {
      if (year != null) {
        return DateTime(year, month, day);
      }

      var candidate = DateTime(now.year, month, day);
      final today = DateTime(now.year, now.month, now.day);
      if (candidate.isBefore(today)) {
        candidate = DateTime(now.year + 1, month, day);
      }
      return candidate;
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseDateTime(String datum, String zeit) {
    final dateOnly = _parseDateOnly(datum);
    if (dateOnly == null) return null;

    final timeParts = zeit.split(':');
    if (timeParts.length != 2) return null;
    final hour = int.tryParse(timeParts[0].trim());
    final minute = int.tryParse(timeParts[1].trim());
    if (hour == null || minute == null) return null;

    try {
      return DateTime(
        dateOnly.year,
        dateOnly.month,
        dateOnly.day,
        hour,
        minute,
      );
    } catch (_) {
      return null;
    }
  }

  String _computeWeekdayLabel(DateTime? dateObj) {
    if (dateObj == null) return '??';
    const labels = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];
    return labels[dateObj.weekday % 7];
  }

  String _inferTerminType(String event) {
    final lower = event.toLowerCase();
    if (lower.contains('training')) return 'Training';
    if (lower.contains('spiel') ||
        lower.contains('testspiel') ||
        lower.contains('freundschaftsspiel')) {
      return 'Spiel';
    }
    if (lower.contains('meeting') ||
        lower.contains('treffen') ||
        lower.contains('besprechung')) {
      return 'Sonstiges';
    }
    return 'Sonstiges';
  }

  void _toggleExpandTermin(int index) {
    setState(() {
      _expandedTermine[index] = !(_expandedTermine[index] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool wappenOpen = _currentWappenSubView != 'closed';
    final bool isVereinsManagementDashboard =
        _currentWappenSubView == 'vereins_management_dashboard';
    final String wappenTitle = isVereinsManagementDashboard
        ? 'Vereins Management'
        : _currentWappenSubView == 'news'
        ? 'News & Ankündigungen'
        : _currentWappenSubView == 'members'
        ? 'Vorstand & Funktionäre'
        : _currentWappenSubView == 'account_linking'
        ? 'Konten verknüpfen / Freigeben'
        : _currentWappenSubView == 'create_user'
        ? 'Neues Profil anlegen'
        : _currentWappenSubView == 'approval_audit'
        ? 'Freigabe-Protokoll'
        : _currentWappenSubView == 'vereins_formulare'
        ? 'Formulare & Anträge'
        : _currentWappenSubView == 'trainings_planer'
        ? 'Trainingsplaner'
        : _currentWappenSubView == 'feedback'
        ? 'Feedback & Beschwerden'
        : 'Vereins-Organisation';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kDarkBackground,
        centerTitle: true,
        leading: wappenOpen
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(
                  () => _currentWappenSubView = isVereinsManagementDashboard
                      ? 'overview'
                      : 'closed',
                ),
              )
            : null,
        title: wappenOpen
            ? Text(
                wappenTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : GestureDetector(
                onTap: () => setState(() => _currentWappenSubView = 'overview'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: kCardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        'lib/assets/app_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'TV Friedrichstein',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
        actions: [
          if (!wappenOpen && _isVereinsAdmin)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.amberAccent),
              tooltip: tr('club_org'),
              onPressed: () => _showVereinsWappenEditor(context),
            ),
          if (_isCoachOrAdmin) ...[
            IconButton(
              icon: const Icon(
                Icons.event_available,
                color: Colors.greenAccent,
              ),
              tooltip: tr('create_termin'),
              onPressed: () => _showKombiniertenTerminPlaner(context),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.blueAccent),
            tooltip: tr('person_add'),
            onPressed: () => _showSpielerImportDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white70),
            tooltip: tr('language'),
            onPressed: _showLanguagePicker,
          ),
          if (widget.onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              tooltip: 'Abmelden',
              onPressed: widget.onLogout,
            ),
        ],
      ),

      // SWITCH-CASE LOGIK FÜR DIE UNTERSCHIEDLICHEN SEITEN JE NACH NAVIGATION
      body: _currentWappenSubView != 'closed'
          ? _buildWappenBody()
          : _buildSelectedBody(),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kDarkBackground,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            // INTELLIGENTE NAVIGATION: Subviews resetten wenn Tab gewechselt wird
            // Bonus: Double-Tap auf gleichen Tab resetzt auch die Subviews

            // Prüfe ob Nutzer auf GLEICHEN Tab tippt (Double-Tap)
            final bool isDoubleTap = _selectedIndex == index;

            // Hauptindex wechseln
            _selectedIndex = index;

            // ALLE SUBVIEW-STATES AUF STARTWERTE ZURÜCKSETZEN
            // Dies verhindert, dass Nutzer in tiefe Unteransichten "steckenbleiben"
            _currentKommSubView =
                'overview'; // Kommunikation zurück zur Übersicht
            _currentTeamSubView = 'uebersicht'; // Team zurück zur Hauptliste
            _currentTerminSubView = 'list'; // Termine zurück zur Liste
            _currentWappenSubView =
                'closed'; // Vereinsverwaltung zur Startseite
            _terminFilterType = 'Alle'; // Filter auf Standard zurücksetzen

            // HAPTIC FEEDBACK: Gib dem Benutzer ein "klik" Gefühl
            if (isDoubleTap) {
              // Double-Tap triggert stärkeres Feedback
              HapticFeedback.mediumImpact();
            } else {
              // Normaler Tap bekommt leichtes Feedback
              HapticFeedback.lightImpact();
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: tr('nav_home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: tr('nav_communication'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.star),
            label: tr('nav_team'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: tr('nav_schedule'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: tr('nav_profile'),
          ),
        ],
      ),
    );
  }

  // Schaltet die Karosserie der App basierend auf dem ausgewählten Tab um
  Widget _buildSelectedBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardBody();
      case 1:
        return _buildKommunikationBody();
      case 2:
        return _buildTeamBody();
      case 3:
        return _buildAllTermineBody();
      case 4:
        return _buildPersonalBody();
      default:
        return _buildDashboardBody();
    }
  }

  Widget _buildWappenBody() {
    switch (_currentWappenSubView) {
      case 'news':
        return _buildWappenNewsView();
      case 'members':
        return _buildWappenMembersView();
      case 'account_linking':
        return _buildKontenFreigabeView();
      case 'create_user':
        return _buildAdminCreateUserScreen();
      case 'approval_audit':
        return _buildFreigabeAuditView();
      case 'vereins_management_dashboard':
        return _buildVereinsManagementDashboardSubView();
      case 'vereins_formulare':
        return _buildVereinsFormulareSubView();
      case 'trainings_planer':
        return _buildTrainingsPlanerSubView();
      case 'dfbnet_import':
        return _buildDfbnetImportAssistentSubView();
      case 'feedback':
        return _buildWappenFeedbackView();
      case 'overview':
      default:
        return _buildWappenOverview();
    }
  }

  Widget _buildWappenOverview() {
    const allowedStaffRoles = [
      'Vereinsadministrator',
      'Trainer',
      'Co-Trainer',
      'Betreuer',
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          tr('club_org'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tr('club_org_desc'),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 24),
        if (_hasAnyRole(allowedStaffRoles))
          _buildWappenNavCard(
            title: 'Vereins Management',
            subtitle:
                'Konten verknüpfen, Profile einpflegen und Freigabe-Protokolle einsehen.',
            icon: Icons.admin_panel_settings,
            color: Colors.tealAccent,
            target: 'vereins_management_dashboard',
          ),
        if (_isCoachOrAdmin)
          Card(
            color: kCardColor,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Colors.white10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Globale Vereins-Einstellungen',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Mannschaften verwalten und Vereinsstruktur zentral anpassen.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                        ),
                        onPressed: _isVereinsAdmin ? _showAddTeamDialog : null,
                        icon: const Icon(Icons.group_add),
                        label: const Text('Neue Mannschaft anlegen'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isVereinsAdmin
                            ? _showManageTeamsDialog
                            : null,
                        icon: const Icon(Icons.settings),
                        label: const Text('Mannschaften verwalten'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        _buildWappenNavCard(
          title: tr('club_news'),
          subtitle: tr('club_news_desc'),
          icon: Icons.newspaper,
          color: Colors.blueAccent,
          target: 'news',
        ),
        _buildWappenNavCard(
          title: tr('club_members'),
          subtitle: tr('club_members_desc'),
          icon: Icons.group,
          color: Colors.tealAccent,
          target: 'members',
        ),
        _buildWappenNavCard(
          title: tr('club_feedback'),
          subtitle: tr('club_feedback_desc'),
          icon: Icons.feedback,
          color: Colors.orangeAccent,
          target: 'feedback',
        ),
      ],
    );
  }

  Widget _buildWappenNewsView() {
    return const VereinsNewsOverview();
  }

  Widget _buildWappenMembersView() {
    final sortedMembers = List<Map<String, dynamic>>.from(_vereinsMitglieder)
      ..sort((a, b) {
        int priority(Map<String, dynamic> member) {
          final roleTexts = [
            ...((member['rollen'] as List?)?.map((role) => role.toString()) ??
                const <String>[]),
            member['rolle']?.toString() ?? '',
          ].where((role) => role.trim().isNotEmpty).toList();

          if (roleTexts.any(
            (role) => role.toLowerCase().contains('vorstand'),
          )) {
            return 0;
          }

          final roles = roleTexts.toSet();
          if (roles.contains('Vereinsadministrator')) return 1;
          if (roles.contains('Trainer')) return 2;
          if (roles.contains('Co-Trainer')) return 3;
          if (roles.contains('Betreuer')) return 4;
          return 5;
        }

        final byPriority = priority(a).compareTo(priority(b));
        if (byPriority != 0) return byPriority;
        return (a['name']?.toString() ?? '').compareTo(
          b['name']?.toString() ?? '',
        );
      });

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          tr('members_officials'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tr('members_officials_desc'),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 20),
        ...sortedMembers.map((member) {
          final allowed = (member['erlaubteTeams'] as List?) ?? <dynamic>[];
          final allowedText = allowed.map((e) => e.toString()).join(', ');
          return Card(
            color: kCardColor,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white10),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.tealAccent.withValues(alpha: 0.16),
                child: Text(
                  member['name'].toString().substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                member['name'] as String,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${member['rolle']} • ${member['kontakt']}\nTeams: $allowedText',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: SizedBox(
                width: 84,
                child: Text(
                  member['phone'] as String,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWappenFeedbackView() {
    final bool canEditFeedback = _isCoachOrAdmin;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          tr('club_feedback'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tr('feedback_manage_desc'),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 20),
        if (canEditFeedback)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.add_comment),
              label: Text(tr('new_feedback_create')),
              onPressed: () => _showFeedbackErstellenDialog(),
            ),
          ),
        ..._vereinsFeedback.map((ticket) {
          final bool isOpen = ticket['status'] == 'Offen';
          return Card(
            color: kCardColor,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ticket['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildFeedbackStatusChip(ticket['status'] as String),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket['message'] as String,
                    style: const TextStyle(color: Colors.grey, height: 1.4),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${ticket['submittedBy']} • ${ticket['date']}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (canEditFeedback)
                        TextButton(
                          onPressed: isOpen
                              ? () =>
                                    _updateFeedbackStatus(ticket, 'Bearbeitet')
                              : null,
                          child: Text(tr('mark_done')),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWappenNavCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String target,
  }) {
    return Card(
      color: kCardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 18,
        ),
        onTap: () => setState(() => _currentWappenSubView = target),
      ),
    );
  }

  void _showFeedbackErstellenDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String submitter = _currentUserName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: Text(
          tr('new_feedback_capture'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: SizedBox(
          width: adaptiveDialogWidth(context),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: tr('title_label')),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: tr('description_label'),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () {
              if (titleController.text.trim().isEmpty ||
                  messageController.text.trim().isEmpty) {
                return;
              }
              setState(() {
                _vereinsFeedback.insert(0, {
                  'title': titleController.text.trim(),
                  'status': 'Offen',
                  'message': messageController.text.trim(),
                  'submittedBy': submitter,
                  'date': DateTime.now()
                      .toString()
                      .substring(0, 10)
                      .replaceAll('-', '.'),
                });
              });
              Navigator.pop(context);
            },
            child: Text(tr('save')),
          ),
        ],
      ),
    );
  }

  void _updateFeedbackStatus(Map<String, dynamic> ticket, String status) {
    setState(() {
      ticket['status'] = status;
    });
  }

  Widget _buildFeedbackStatusChip(String status) {
    final color = status == 'Offen' ? Colors.redAccent : Colors.greenAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEditableTeamPhotoCard() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: _teamPhotoBytes == null ? _teamPhotoColor : null,
            image: _teamPhotoBytes != null
                ? DecorationImage(
                    image: MemoryImage(_teamPhotoBytes!),
                    fit: BoxFit.cover,
                  )
                : const DecorationImage(
                    image: AssetImage(
                      'lib/assets/Mannschaftsfoto_c_jugend.png',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Color.fromARGB(77, 0, 0, 0),
                      BlendMode.darken,
                    ),
                  ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x33808080)),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_teamPhotoBytes == null)
                    const Icon(Icons.group, size: 36, color: Colors.white),
                  const Spacer(),
                  Text(
                    _teamPhotoCaption,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Mannschafts Foto bearbeiten',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isCoachOrAdmin)
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () => _showTeamFotoEditor(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.edit, color: Colors.white, size: 18),
              ),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SEITE 0: DAS HAUPT-DASHBOARD (STARTSEITE)
  // ─────────────────────────────────────────────────────────────────
  Widget _buildDashboardBody() {
    final visibleTeams = _visibleTeamsForCurrentUser;
    final visibleTeamIds = _visibleTeamIdsForCurrentUser;
    final String? teamDropdownValue = visibleTeamIds.contains(_selectedTeamId)
        ? _selectedTeamId
        : (visibleTeamIds.isNotEmpty ? visibleTeamIds.first : null);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('welcome_back'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(_selectedTeamName, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),

          // MANNSCHAFTSAUSWAHL
          Row(
            children: [
              const Text('Mannschaft:', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: teamDropdownValue,
                      isExpanded: true,
                      dropdownColor: kCardColor,
                      items: visibleTeams.map((team) {
                        final id = team['id'] as String;
                        final name = (team['name'] as String?) ?? id;
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text(
                            name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: visibleTeams.isEmpty
                          ? null
                          : (value) {
                              if (value != null) {
                                _switchSelectedTeam(value);
                              }
                            },
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (visibleTeams.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Keine Mannschaft fuer dieses Profil freigeschaltet.',
                style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
              ),
            ),
          if (_hasRole('Vereinsadministrator')) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showAddTeamDialog,
                icon: const Icon(Icons.add),
                label: const Text('+ Neue Mannschaft anlegen'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showManageTeamsDialog,
                icon: const Icon(Icons.settings),
                label: const Text('Mannschaften verwalten'),
              ),
            ),
          ],
          const SizedBox(height: 12),

          // LOGIN-KONTEXT (READ-ONLY)
          Row(
            children: [
              const Text('Benutzer:', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _currentUserName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(tr('my_role'), style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _currentUserRole,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: _buildEditableTeamPhotoCard(),
          ),
          const SizedBox(height: 20),
          if (_hasOpenAbstimmungen())
            _buildDashboardInfoBanner(
              tr('open_vote_banner_title'),
              tr(
                'open_vote_banner_text',
              ).replaceAll('{count}', _getOpenAbstimmungenCount().toString()),
              Icons.how_to_vote,
              Colors.orangeAccent,
            ),
          if (_currentUserDebt() > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: _buildDashboardInfoBanner(
                tr('open_amount_banner_title'),
                tr('open_amount_banner_text').replaceAll(
                  '{amount}',
                  _currentUserDebt().toStringAsFixed(2).replaceAll('.', ','),
                ),
                Icons.euro,
                Colors.redAccent,
              ),
            ),
          const SizedBox(height: 25),

          // VORSCHAU NÄCHSTE TERMINE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('next_events'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => setState(
                  () => _selectedIndex = 3,
                ), // Springt direkt zum Termin-Tab
                child: Text(
                  tr('show_all'),
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Zeige nur Termine der nächsten 7 Tage auf der Startseite
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kPrimaryColor, width: 1),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: (() {
                final wi = _getTermineIndicesNextWeek();
                if (wi.isEmpty) {
                  return [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        tr('no_events_next_7_days'),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ];
                }
                return wi
                    .map((i) => _buildWeeklyTerminRow(i, _allTermine[i]))
                    .toList();
              })(),
            ),
          ),
          const SizedBox(height: 30),

          // ─────────────────────────────────────────────────────────────────
          // LIVE-TABELLE (Ganze Tabelle komplett sichtbar)
          // ─────────────────────────────────────────────────────────────────
          Text(
            tr('live_table_title'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          SizedBox(
            height:
                950, // ─ Erhöht von 600 auf 1200, damit alle Plätze hinpassen
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const TabelleScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryKlickCard(
    String titel,
    String beschreibung,
    IconData icon,
    Color iconFarbe,
    VoidCallback target, {
    String? badgeLabel,
    Color badgeColor = Colors.purpleAccent,
  }) {
    return Card(
      color: kCardColor,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconFarbe.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconFarbe, size: 28),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                titel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (badgeLabel != null && badgeLabel.trim().isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.6)),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            beschreibung,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: target,
      ),
    );
  }

  Widget _buildRechteGesperrtSeite(String meldung, {VoidCallback? onBack}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              meldung,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed:
                  onBack ??
                  () => setState(() => _currentKommSubView = 'overview'),
              child: Text(tr('back_to_overview')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKommunikationBody() {
    switch (_currentKommSubView) {
      case 'chats':
        return _buildChatsSubView();
      case 'new_chat_select':
        return _buildNewChatSelectSubView();
      case 'active_chat':
        return _buildActiveChatScreen();
      case 'anmerkungen':
        return _buildAnmerkungenSubView();
      case 'abstimmungen':
        return _buildAbstimmungenSubView();
      case 'overview':
      default:
        return _buildKommOverview();
    }
  }

  Widget _buildVereinsManagementDashboardSubView() {
    const allowedStaffRoles = [
      'Vereinsadministrator',
      'Trainer',
      'Co-Trainer',
      'Betreuer',
    ];
    if (!_hasAnyRole(allowedStaffRoles)) {
      return _buildRechteGesperrtSeite(
        'Nur Vereinsadministrator, Trainer, Co-Trainer und Betreuer duerfen das Vereins Management oeffnen.',
        onBack: () => setState(() => _currentWappenSubView = 'overview'),
      );
    }

    final pendingApprovals = _wartendeKonten.length;
    final auditCount = _freigabeAuditLog.length;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isUltraSmallScreen = screenWidth < 320;
    final bool isVerySmallScreen = screenWidth < 360;
    final bool isTabletOrLarger = screenWidth >= 900;
    final int dashboardCrossAxisCount = isUltraSmallScreen
        ? 1
        : isTabletOrLarger
        ? 3
        : 2;
    final double dashboardSpacing = isVerySmallScreen ? 12 : 16;
    final double dashboardAspectRatio = isUltraSmallScreen
        ? 1.34
        : isVerySmallScreen
        ? 0.86
        : 0.72;
    final double tilePadding = isVerySmallScreen ? 12 : 16;
    final double tileIconPadding = isVerySmallScreen ? 8 : 10;
    final double tileIconSize = isVerySmallScreen ? 22 : 26;
    final double tileTitleSize = isVerySmallScreen ? 14.5 : 16;
    final double tileDescriptionSize = isVerySmallScreen ? 10.5 : 11.5;
    final double tileCtaSize = isVerySmallScreen ? 11 : 12;

    Widget buildDashboardTile({
      required String title,
      required String description,
      required IconData icon,
      required Color iconColor,
      required VoidCallback onTap,
      int? badgeCount,
    }) {
      final bool showBadge = (badgeCount ?? 0) > 0;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          splashColor: iconColor.withValues(alpha: 0.20),
          highlightColor: iconColor.withValues(alpha: 0.10),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2A1018).withValues(alpha: 0.92),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(tilePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(tileIconPadding),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: iconColor, size: tileIconSize),
                      ),
                      SizedBox(height: isVerySmallScreen ? 8 : 12),
                      Text(
                        title,
                        maxLines: isVerySmallScreen ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: tileTitleSize,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: isVerySmallScreen ? 6 : 8),
                      Expanded(
                        child: Text(
                          description,
                          maxLines: isVerySmallScreen ? 4 : 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: tileDescriptionSize,
                            height: 1.35,
                          ),
                        ),
                      ),
                      SizedBox(height: isVerySmallScreen ? 6 : 8),
                      Row(
                        children: [
                          Text(
                            'Jetzt oeffnen',
                            style: TextStyle(
                              color: iconColor,
                              fontWeight: FontWeight.w700,
                              fontSize: tileCtaSize,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward,
                            color: iconColor,
                            size: isVerySmallScreen ? 14 : 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showBadge)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 900),
                      tween: Tween<double>(begin: 0.94, end: 1.08),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: 0.55),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A1E2C).withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF7A1E2C).withValues(alpha: 0.55),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFD86A7E),
                    ),
                    onPressed: () =>
                        setState(() => _currentWappenSubView = 'overview'),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Vereins Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hier sind die administrativen Werkzeuge fuer dein Team.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: dashboardCrossAxisCount,
              mainAxisSpacing: dashboardSpacing,
              crossAxisSpacing: dashboardSpacing,
              childAspectRatio: dashboardAspectRatio,
              children: [
                buildDashboardTile(
                  title: 'Konten verknuepfen / Freigeben',
                  description:
                      'Neue Registrierungen pruefen und sofort sauber fuer Mannschaften freischalten.',
                  icon: Icons.how_to_reg,
                  iconColor: Colors.tealAccent,
                  badgeCount: pendingApprovals,
                  onTap: () =>
                      setState(() => _currentWappenSubView = 'account_linking'),
                ),
                buildDashboardTile(
                  title: 'Neues Profil anlegen',
                  description:
                      'Neue Spieler oder Staff-Mitglieder mit Start-Passwort und Teamzuordnung anlegen.',
                  icon: Icons.person_add,
                  iconColor: Colors.amberAccent,
                  onTap: () =>
                      setState(() => _currentWappenSubView = 'create_user'),
                ),
                buildDashboardTile(
                  title: 'Freigabe-Protokoll',
                  description:
                      'Alle Freigaben und Zuordnungen im Verein transparent und nachvollziehbar einsehen.',
                  icon: Icons.history,
                  iconColor: Colors.blueAccent,
                  badgeCount: auditCount > 0 ? auditCount : null,
                  onTap: () =>
                      setState(() => _currentWappenSubView = 'approval_audit'),
                ),
                buildDashboardTile(
                  title: 'Formulare & Antraege',
                  description:
                      'Passantraege, Vereinsanmeldungen und weitere Dokumente zentral verwalten.',
                  icon: Icons.description,
                  iconColor: Colors.purpleAccent,
                  onTap: () => setState(
                    () => _currentWappenSubView = 'vereins_formulare',
                  ),
                ),
                buildDashboardTile(
                  title: 'Trainingsplaner',
                  description:
                      'Trainingseinheiten planen, im Archiv speichern und direkt mit dem Trainerteam teilen.',
                  icon: Icons.fitness_center,
                  iconColor: Colors.orangeAccent,
                  onTap: () => setState(
                    () => _currentWappenSubView = 'trainings_planer',
                  ),
                ),
                buildDashboardTile(
                  title: 'DFBnet-Import Assistent',
                  description:
                      'Kader aus DFBnet-CSV importieren und automatisch Mannschaften zuweisen.',
                  icon: Icons.upload_file,
                  iconColor: Colors.greenAccent,
                  onTap: () =>
                      setState(() => _currentWappenSubView = 'dfbnet_import'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndImportDfbnetCsv() async {
    if (!_hasAnyRole(_kBroadcastAllowedRoles)) {
      _showAppSnack(
        'Nur Trainerteam und Vereinsadministratoren duerfen DFBnet-Importe ausfuehren.',
      );
      return;
    }

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
      );

      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        _showAppSnack(
          'Die CSV-Datei konnte nicht gelesen werden. Bitte erneut auswaehlen.',
        );
        return;
      }

      String csvInhalt;
      try {
        csvInhalt = utf8.decode(bytes, allowMalformed: true);
      } catch (_) {
        csvInhalt = latin1.decode(bytes, allowInvalid: true);
      }

      final team = _vereinsTeams.firstWhere(
        (t) => (t['id'] as String?) == _dfbnetImportSelectedTeamId,
        orElse: () => _selectedTeam,
      );
      final mannschaftsName =
          (team['name'] as String?) ?? _dfbnetImportSelectedTeamId;
      final preview = _parseDfbnetCsvPreview(csvInhalt);
      final rows = (preview['rows'] as List).cast<Map<String, String>>();
      final totalRows = (preview['totalRows'] as int?) ?? 0;
      final validRows = (preview['validRows'] as int?) ?? 0;
      final skippedRows = (preview['skippedRows'] as int?) ?? 0;

      if (totalRows == 0 || validRows == 0) {
        _showAppSnack(
          'Keine gueltigen Spielerdaten in der CSV erkannt. Bitte DFBnet-Export pruefen.',
        );
        return;
      }

      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: kCardColor,
          title: const Text('DFBnet-Import Vorschau'),
          content: SizedBox(
            width: adaptiveDialogWidth(context, desktopWidth: 680),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mannschaft: $mannschaftsName',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Datensaetze erkannt: $totalRows • Gueltig: $validRows • Uebersprungen: $skippedRows',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Vorschau (erste 10 Spieler):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (rows.isEmpty)
                    const Text('Keine Vorschau verfuegbar.')
                  else
                    ...rows.map((row) {
                      final name = row['name']?.trim().isNotEmpty == true
                          ? row['name']!
                          : 'Unbekannt';
                      final birth =
                          row['geburtsdatum']?.trim().isNotEmpty == true
                          ? row['geburtsdatum']!
                          : '-';
                      final pass = row['passNummer'] ?? '-';
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.person,
                          color: Colors.greenAccent,
                          size: 18,
                        ),
                        title: Text(name),
                        subtitle: Text('Geburt: $birth • Pass: $pass'),
                      );
                    }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr('cancel')),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.playlist_add_check),
              label: const Text('Import starten'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      importiereDFBnetKader(csvInhalt, mannschaftsName);

      if (widget.onAuthDataChanged != null) {
        await widget.onAuthDataChanged!.call();
      }
    } on MissingPluginException {
      _showAppSnack(
        'Dateiauswahl ist noch nicht nativerseitig geladen. Bitte App komplett neu starten (kein Hot-Reload).',
      );
    } on PlatformException catch (error) {
      final details = error.message?.trim();
      _showAppSnack(
        details == null || details.isEmpty
            ? 'CSV-Auswahl fehlgeschlagen. Bitte erneut versuchen.'
            : 'CSV-Auswahl fehlgeschlagen: $details',
      );
    } catch (_) {
      _showAppSnack('Unerwarteter Fehler beim DFBnet-Import.');
    }
  }

  Widget _buildDfbnetImportAssistentSubView() {
    const allowedStaffRoles = [
      'Vereinsadministrator',
      'Trainer',
      'Co-Trainer',
      'Betreuer',
    ];
    if (!_hasAnyRole(allowedStaffRoles)) {
      return _buildRechteGesperrtSeite(
        'Nur Vereinsadministrator, Trainer, Co-Trainer und Betreuer duerfen den DFBnet-Import nutzen.',
        onBack: () => setState(
          () => _currentWappenSubView = 'vereins_management_dashboard',
        ),
      );
    }

    final teams = List<Map<String, dynamic>>.from(_vereinsTeams);
    final selectedTeamId =
        teams.any((t) => t['id'] == _dfbnetImportSelectedTeamId)
        ? _dfbnetImportSelectedTeamId
        : ((teams.first['id'] as String?) ?? 'c_jugend');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(
                () => _currentWappenSubView = 'vereins_management_dashboard',
              ),
            ),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'DFBnet-Import Assistent',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Importiere Kaderdaten aus einem DFBnet-CSV-Export und ordne Spieler automatisch deiner Mannschaft zu.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 18),
        Card(
          color: kCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedTeamId,
                  dropdownColor: kCardColor,
                  decoration: const InputDecoration(
                    labelText: 'Mannschaft auswaehlen',
                  ),
                  items: teams.map((team) {
                    final id = (team['id'] as String?) ?? '';
                    final name = (team['name'] as String?) ?? id;
                    final saison = (team['saison'] as String?) ?? '-';
                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(
                        '$name ($saison)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _dfbnetImportSelectedTeamId = value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _dfbnetImportSaison,
                  onChanged: (value) {
                    final trimmed = value.trim();
                    if (trimmed.isNotEmpty) {
                      _dfbnetImportSaison = trimmed;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Saison',
                    hintText: 'z.B. 2026/27',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      setState(
                        () => _dfbnetImportSelectedTeamId = selectedTeamId,
                      );
                      _pickAndImportDfbnetCsv();
                    },
                    icon: const Icon(Icons.file_upload),
                    label: const Text(
                      'DFBnet-Exportdatei (.csv) auswaehlen',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_dfbnetImportResultMessage.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _dfbnetImportResultSuccess
                  ? Colors.green.withValues(alpha: 0.16)
                  : Colors.redAccent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _dfbnetImportResultSuccess
                    ? Colors.greenAccent.withValues(alpha: 0.5)
                    : Colors.redAccent.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              _dfbnetImportResultMessage,
              style: TextStyle(
                color: _dfbnetImportResultSuccess
                    ? Colors.greenAccent
                    : Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrainingsPlanerSubView() {
    if (!_canManageVorbereitung) {
      return _buildRechteGesperrtSeite(
        'Nur Trainer und Vereinsadministratoren duerfen den Trainingsplaner oeffnen.',
        onBack: () => setState(
          () => _currentWappenSubView = 'vereins_management_dashboard',
        ),
      );
    }

    final archive = List<Map<String, dynamic>>.from(_trainingsEinheiten)
      ..sort(
        (a, b) => (b['erstelltAm']?.toString() ?? '').compareTo(
          a['erstelltAm']?.toString() ?? '',
        ),
      );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(
                () => _currentWappenSubView = 'vereins_management_dashboard',
              ),
            ),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Digitaler Trainingsplaner',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Erstelle Einheiten strukturiert, speichere sie im Archiv und teile den Ablauf direkt im Trainerteam.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 18),
        Card(
          color: kCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _trainingFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Neue Einheit erstellen',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _trainingsSchwerpunkt,
                    dropdownColor: kCardColor,
                    decoration: const InputDecoration(labelText: 'Schwerpunkt'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bitte Schwerpunkt auswaehlen.';
                      }
                      return null;
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'Aufwaermen',
                        child: Text('Aufwaermen'),
                      ),
                      DropdownMenuItem(
                        value: 'Passspiel',
                        child: Text('Passspiel'),
                      ),
                      DropdownMenuItem(
                        value: 'Torschuss',
                        child: Text('Torschuss'),
                      ),
                      DropdownMenuItem(
                        value: 'Spielesammlung',
                        child: Text('Spielesammlung'),
                      ),
                      DropdownMenuItem(
                        value: 'Athletik/Fitness',
                        child: Text('Athletik/Fitness'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _trainingsSchwerpunkt = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Verfuegbare Trainingszeit: ${_trainingsZeitMinuten.round()} Minuten',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: _trainingsZeitMinuten,
                    min: 60,
                    max: 120,
                    divisions: 2,
                    label: _trainingsZeitMinuten.round().toString(),
                    onChanged: (value) =>
                        setState(() => _trainingsZeitMinuten = value),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _hauptuebung1Controller,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bitte Hauptuebung 1 eintragen.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Hauptuebung 1 (Ablauf & Coaching-Punkte)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _hauptuebung2Controller,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bitte Hauptuebung 2 eintragen.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Hauptuebung 2 (Ablauf & Coaching-Punkte)',
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                      ),
                      onPressed: _createTrainingseinheit,
                      icon: const Icon(Icons.save),
                      label: const Text('Einheit speichern'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Trainings-Archiv (${archive.length})',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (archive.isEmpty)
          const Card(
            color: kCardColor,
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Noch keine Trainingseinheiten gespeichert.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...archive.map((einheit) {
            final fokus = einheit['schwerpunkt']?.toString() ?? '-';
            final minuten = einheit['zeitMinuten']?.toString() ?? '-';
            final erstellt = einheit['erstelltAm']?.toString() ?? '-';
            return Card(
              color: kCardColor,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x33FFAB40),
                  child: Icon(Icons.fitness_center, color: Colors.orangeAccent),
                ),
                title: Text('$fokus • $minuten Min'),
                subtitle: Text('Erstellt am $erstellt'),
                onTap: () => _showTrainingseinheitDetails(einheit),
                trailing: IconButton(
                  tooltip: 'Teilen',
                  icon: const Icon(Icons.share, color: Colors.orangeAccent),
                  onPressed: () => _shareTrainingseinheit(einheit),
                ),
              ),
            );
          }),
      ],
    );
  }

  void _createTrainingseinheit() {
    final formState = _trainingFormKey.currentState;
    if (formState == null || !formState.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte alle Pflichtfelder korrekt ausfuellen.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final uebung1 = _hauptuebung1Controller.text.trim();
    final uebung2 = _hauptuebung2Controller.text.trim();

    final einheit = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'schwerpunkt': _trainingsSchwerpunkt,
      'zeitMinuten': _trainingsZeitMinuten.round(),
      'hauptuebung1': uebung1,
      'hauptuebung2': uebung2,
      'erstelltAm': _formatTodayForList(),
    };

    setState(() {
      _trainingsEinheiten.insert(0, einheit);
      _hauptuebung1Controller.clear();
      _hauptuebung2Controller.clear();
      _trainingsSchwerpunkt = 'Aufwaermen';
      _trainingsZeitMinuten = 90;
      _trainingFormKey.currentState?.reset();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trainingseinheit gespeichert.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatTrainingseinheitForShare(Map<String, dynamic> einheit) {
    return '''Trainingsplan\n\nSchwerpunkt: ${einheit['schwerpunkt']}\nZeit: ${einheit['zeitMinuten']} Minuten\nErstellt am: ${einheit['erstelltAm']}\n\nHauptuebung 1:\n${einheit['hauptuebung1']}\n\nHauptuebung 2:\n${einheit['hauptuebung2']}''';
  }

  Future<void> _shareTrainingseinheit(Map<String, dynamic> einheit) async {
    final text = _formatTrainingseinheitForShare(einheit);
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: 'Trainingsplan ${einheit['schwerpunkt'] ?? ''}',
        ),
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Teilen nicht verfuegbar. Trainingsablauf wurde in die Zwischenablage kopiert.',
          ),
        ),
      );
    }
  }

  Future<void> _showTrainingseinheitDetails(
    Map<String, dynamic> einheit,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: Text(
          '${einheit['schwerpunkt']} • ${einheit['zeitMinuten']} Min',
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Erstellt am: ${einheit['erstelltAm']}'),
              const SizedBox(height: 12),
              const Text(
                'Hauptuebung 1',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(einheit['hauptuebung1']?.toString() ?? '-'),
              const SizedBox(height: 12),
              const Text(
                'Hauptuebung 2',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(einheit['hauptuebung2']?.toString() ?? '-'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('close')),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () => _shareTrainingseinheit(einheit),
            icon: const Icon(Icons.share),
            label: const Text('Teilen'),
          ),
        ],
      ),
    );
  }

  Future<void> _openVereinsFormular(Map<String, dynamic> formular) async {
    final path = formular['path']?.toString() ?? '';
    if (path.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Für dieses Formular ist derzeit noch keine PDF-Datei hinterlegt.',
          ),
        ),
      );
      return;
    }

    final uri = Uri.file(path);
    final canOpen = await canLaunchUrl(uri);
    if (!canOpen) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formular konnte nicht geöffnet werden.')),
      );
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWhatsApp({
    required String telefonnummer,
    String? text,
  }) async {
    final trimmed = telefonnummer.trim();
    final saubereNummer = trimmed.replaceAll(RegExp(r'[^\d+]'), '');
    final nummerNurZiffern = saubereNummer.replaceAll(RegExp(r'\D'), '');

    if (nummerNurZiffern.isEmpty) {
      throw 'WhatsApp konnte nicht geoeffnet werden: Telefonnummer fehlt.';
    }

    final message = text?.trim();
    final Uri nativeUri = Uri.parse(
      message != null && message.isNotEmpty
          ? 'whatsapp://send?phone=$nummerNurZiffern&text=${Uri.encodeComponent(message)}'
          : 'whatsapp://send?phone=$nummerNurZiffern',
    );
    if (await canLaunchUrl(nativeUri)) {
      await launchUrl(
        nativeUri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      return;
    }

    final Uri webUri = Uri.parse(
      message != null && message.isNotEmpty
          ? 'https://wa.me/$nummerNurZiffern?text=${Uri.encodeComponent(message)}'
          : 'https://wa.me/$nummerNurZiffern',
    );

    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    throw 'WhatsApp konnte nicht geoeffnet werden';
  }

  void _showAppSnack(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _resolveWhatsAppNummer(Map<String, dynamic> mitglied) {
    final kandidat = [
      mitglied['mobil'],
      mitglied['notfallTelefon'],
      mitglied['phone'],
    ];
    for (final value in kandidat) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text != '-') return text;
    }
    return '';
  }

  Future<void> _openWhatsAppForMitglied(Map<String, dynamic> mitglied) async {
    final nummer = _resolveWhatsAppNummer(mitglied);
    if (nummer.isEmpty) {
      _showAppSnack(
        'Fuer dieses Mitglied ist keine WhatsApp-Nummer hinterlegt.',
      );
      return;
    }

    try {
      await _openWhatsApp(telefonnummer: nummer);
    } catch (error) {
      _showAppSnack(error.toString());
    }
  }

  Future<void> _sendWhatsAppBroadcast() async {
    if (!_hasAnyRole(_kBroadcastAllowedRoles)) {
      _showAppSnack(
        'Nur Trainerteam und Vereinsadministratoren duerfen Broadcasts senden.',
      );
      return;
    }

    final message = _whatsAppBroadcastController.text.trim();
    if (message.isEmpty) {
      _showAppSnack('Bitte zuerst eine Nachricht eingeben.');
      return;
    }

    final groupInvite =
        (_selectedTeam['whatsappGroupInvite'] as String?)?.trim() ?? '';
    final groupId = (_selectedTeam['whatsappGroupId'] as String?)?.trim() ?? '';

    try {
      if (groupInvite.isNotEmpty) {
        final inviteUri = Uri.tryParse(groupInvite);
        if (inviteUri != null && await canLaunchUrl(inviteUri)) {
          await launchUrl(inviteUri, mode: LaunchMode.externalApplication);
          await Clipboard.setData(ClipboardData(text: message));
          _showAppSnack(
            'Gruppenlink geoeffnet. Nachricht wurde in die Zwischenablage kopiert.',
          );
          return;
        }
      }

      if (groupId.isNotEmpty) {
        await _openWhatsApp(telefonnummer: groupId, text: message);
        _showAppSnack(
          'WhatsApp geoeffnet. Nachricht ist fuer die Gruppe vorbereitet.',
        );
        _whatsAppBroadcastController.clear();
        return;
      }

      await Clipboard.setData(ClipboardData(text: message));
      final pickerUri = Uri.parse(
        'whatsapp://send?text=${Uri.encodeComponent(message)}',
      );
      if (await canLaunchUrl(pickerUri)) {
        await launchUrl(
          pickerUri,
          mode: LaunchMode.externalNonBrowserApplication,
        );
      } else {
        final webUri = Uri.parse(
          'https://wa.me/?text=${Uri.encodeComponent(message)}',
        );
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } else {
          throw 'WhatsApp konnte nicht geoeffnet werden';
        }
      }

      _showAppSnack(
        'WhatsApp geoeffnet. Nachricht ist auch in der Zwischenablage.',
      );
      _whatsAppBroadcastController.clear();
    } catch (error) {
      _showAppSnack(error.toString());
    }
  }

  Future<void> _showWhatsAppGroupSetupDialog() async {
    if (!_hasAnyRole(_kBroadcastAllowedRoles)) {
      _showAppSnack(
        'Nur Trainerteam und Vereinsadministratoren duerfen die WhatsApp-Gruppe konfigurieren.',
      );
      return;
    }

    final groupIdController = TextEditingController(
      text: (_selectedTeam['whatsappGroupId'] as String?)?.trim() ?? '',
    );
    final inviteController = TextEditingController(
      text: (_selectedTeam['whatsappGroupInvite'] as String?)?.trim() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final idValue = groupIdController.text.trim();
            final inviteValue = inviteController.text.trim();
            final isIdValid =
                idValue.isEmpty || _isValidWhatsAppGroupTarget(idValue);
            final isInviteValid =
                inviteValue.isEmpty || _isValidWhatsAppInviteLink(inviteValue);
            final canSave = isIdValid && isInviteValid;

            return AlertDialog(
              backgroundColor: kCardColor,
              title: const Text('WhatsApp-Gruppenziel konfigurieren'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Optional kannst du eine Gruppen-ID oder einen Einladungslink hinterlegen. Einladungslink hat Prioritaet.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: groupIdController,
                      onChanged: (_) => setDialogState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Gruppen-ID / Zielnummer',
                        hintText: 'z.B. +491701234567 oder numerische ID',
                        suffixIcon: Icon(
                          idValue.isEmpty
                              ? Icons.remove_circle_outline
                              : isIdValid
                              ? Icons.check_circle
                              : Icons.error,
                          color: idValue.isEmpty
                              ? Colors.white38
                              : isIdValid
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      idValue.isEmpty
                          ? 'Optional: leer lassen oder gueltige Zielnummer hinterlegen.'
                          : isIdValid
                          ? 'Zielnummer gueltig.'
                          : 'Ungueltig: nur Ziffern und optional ein fuehrendes + sind erlaubt.',
                      style: TextStyle(
                        color: isIdValid ? Colors.white60 : Colors.redAccent,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: inviteController,
                      onChanged: (_) => setDialogState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Einladungslink (optional)',
                        hintText: 'https://chat.whatsapp.com/...',
                        suffixIcon: Icon(
                          inviteValue.isEmpty
                              ? Icons.remove_circle_outline
                              : isInviteValid
                              ? Icons.check_circle
                              : Icons.error,
                          color: inviteValue.isEmpty
                              ? Colors.white38
                              : isInviteValid
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      inviteValue.isEmpty
                          ? 'Optional: leer lassen oder gueltigen Link hinterlegen.'
                          : isInviteValid
                          ? 'Einladungslink gueltig.'
                          : 'Ungueltig: erwartet wird https://chat.whatsapp.com/...',
                      style: TextStyle(
                        color: isInviteValid
                            ? Colors.white60
                            : Colors.redAccent,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(tr('cancel')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kWhatsAppColor,
                  ),
                  onPressed: !canSave
                      ? null
                      : () {
                          setState(() {
                            _selectedTeam['whatsappGroupId'] = idValue;
                            _selectedTeam['whatsappGroupInvite'] = inviteValue;
                          });

                          Navigator.pop(context);
                          _showAppSnack('WhatsApp-Gruppenziel gespeichert.');
                        },
                  child: const Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isValidWhatsAppGroupTarget(String input) {
    final normalized = input.replaceAll(RegExp(r'[^\d+]'), '');
    final onlyDigits = normalized.replaceAll(RegExp(r'\D'), '');
    if (onlyDigits.length < 8 || onlyDigits.length > 20) {
      return false;
    }
    if (normalized.contains('+') && !normalized.startsWith('+')) {
      return false;
    }
    if (normalized.indexOf('+') != normalized.lastIndexOf('+')) {
      return false;
    }
    return true;
  }

  bool _isValidWhatsAppInviteLink(String input) {
    final uri = Uri.tryParse(input);
    if (uri == null) return false;
    if (uri.scheme != 'https') return false;
    final host = uri.host.toLowerCase();
    if (host != 'chat.whatsapp.com' && host != 'www.chat.whatsapp.com') {
      return false;
    }
    final segments = uri.pathSegments
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return segments.isNotEmpty;
  }

  Future<void> _showAddVereinsFormularDialog() async {
    if (!_canApproveAccounts) return;

    final titleController = TextEditingController();
    final customCategoryController = TextEditingController();
    String selectedCategory = 'Passwesen';
    String selectedFileName = '';
    String selectedFilePath = '';
    const categories = [
      'Passwesen',
      'Mitgliedschaft',
      'Einverständniserklärungen',
      'Sonstiges',
      'Neue Kategorie...',
    ];

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: kCardColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Neues Formular hochladen',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Abbrechen',
              ),
            ],
          ),
          content: SizedBox(
            width: adaptiveDialogWidth(context),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titel des Formulars',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    dropdownColor: kCardColor,
                    decoration: const InputDecoration(
                      labelText: 'Unterkategorie',
                    ),
                    items: categories
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  if (selectedCategory == 'Neue Kategorie...') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: customCategoryController,
                      decoration: const InputDecoration(
                        labelText: 'Neue Unterkategorie',
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          final picked = await FilePicker.pickFile(
                            type: FileType.custom,
                            allowedExtensions: const ['pdf'],
                          );

                          if (picked == null) return;
                          final path = picked.path;
                          if (path == null || path.trim().isEmpty) return;

                          setDialogState(() {
                            selectedFileName = picked.name;
                            selectedFilePath = path;
                          });
                        } on MissingPluginException {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Dateiauswahl ist noch nicht nativerseitig geladen. Bitte App komplett neu starten (kein Hot-Reload).',
                              ),
                            ),
                          );
                        } on PlatformException catch (error) {
                          if (!context.mounted) return;
                          final details = error.message?.trim();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                details == null || details.isEmpty
                                    ? 'PDF-Auswahl fehlgeschlagen. Bitte erneut versuchen.'
                                    : 'PDF-Auswahl fehlgeschlagen: $details',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('PDF auswählen'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selectedFileName.isEmpty
                        ? 'Noch keine Datei ausgewählt.'
                        : 'Ausgewählt: $selectedFileName',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () {
                final title = titleController.text.trim();
                final category = selectedCategory == 'Neue Kategorie...'
                    ? customCategoryController.text.trim()
                    : selectedCategory;

                if (title.isEmpty ||
                    category.isEmpty ||
                    selectedFilePath.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Bitte Titel, Kategorie und PDF-Datei angeben.',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  _vereinsFormulare.insert(0, {
                    'id': 'f_${DateTime.now().millisecondsSinceEpoch}',
                    'titel': title,
                    'kategorie': category,
                    'dateiname': selectedFileName,
                    'path': selectedFilePath,
                    'hochgeladenAm': _formatTodayForList(),
                  });
                });

                Navigator.pop(context);
              },
              child: const Text('Formular speichern'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVereinsFormulareSubView() {
    const allowedStaffRoles = [
      'Vereinsadministrator',
      'Trainer',
      'Co-Trainer',
      'Betreuer',
    ];
    if (!_hasAnyRole(allowedStaffRoles)) {
      return _buildRechteGesperrtSeite(
        'Nur Vereinsadministrator, Trainer, Co-Trainer und Betreuer dürfen das Formular-Center öffnen.',
        onBack: () => setState(
          () => _currentWappenSubView = 'vereins_management_dashboard',
        ),
      );
    }

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final formular in _vereinsFormulare) {
      final category =
          (formular['kategorie'] as String?)?.trim().isNotEmpty == true
          ? formular['kategorie'] as String
          : 'Sonstiges';
      grouped
          .putIfAbsent(category, () => <Map<String, dynamic>>[])
          .add(formular);
    }
    final categories = grouped.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(
                () => _currentWappenSubView = 'vereins_management_dashboard',
              ),
            ),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Formulare & Anträge',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Digitale Vereinsdokumente nach Kategorien sortiert verwalten und öffnen.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        if (_canApproveAccounts) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: _showAddVereinsFormularDialog,
              icon: const Icon(Icons.upload_file),
              label: const Text('Neues Formular hochladen'),
            ),
          ),
        ],
        const SizedBox(height: 18),
        if (categories.isEmpty)
          const Card(
            color: kCardColor,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Es sind noch keine Formulare hinterlegt.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...categories.map((category) {
            final formulare = grouped[category]!
              ..sort(
                (a, b) => (a['titel']?.toString() ?? '').compareTo(
                  b['titel']?.toString() ?? '',
                ),
              );

            return Card(
              color: kCardColor,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white10),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                iconColor: Colors.white70,
                collapsedIconColor: Colors.white54,
                title: Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  '${formulare.length} Dokumente',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                children: formulare.map((formular) {
                  final title = formular['titel']?.toString() ?? 'Formular';
                  final fileName = formular['dateiname']?.toString() ?? '-';
                  final uploadedAt =
                      formular['hochgeladenAm']?.toString() ?? '-';

                  return Card(
                    color: kDarkBackground,
                    margin: const EdgeInsets.only(top: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0x3322C55E),
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: Colors.redAccent,
                        ),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '$fileName\nHochgeladen am $uploadedAt',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.open_in_new,
                        color: Colors.white54,
                      ),
                      onTap: () => _openVereinsFormular(formular),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
      ],
    );
  }

  void _openOrCreatePrivatChat(String mitgliedName) {
    final normalizedName = mitgliedName.trim();
    if (normalizedName.isEmpty) return;

    setState(() {
      final existingIndex = _aktivePrivatChats.indexWhere(
        (c) =>
            (c['name']?.toString().trim().toLowerCase() ?? '') ==
            normalizedName.toLowerCase(),
      );
      final exists = existingIndex >= 0;

      if (!exists) {
        _aktivePrivatChats.insert(0, {
          'name': normalizedName,
          'subtitle': 'Neu gestartet',
        });

        _messages.add({
          'chat': normalizedName,
          'sender': 'System',
          'text': 'Privatchat mit $normalizedName gestartet.',
          'time':
              '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} Uhr',
        });
      } else if (existingIndex > 0) {
        final existing = _aktivePrivatChats.removeAt(existingIndex);
        _aktivePrivatChats.insert(0, existing);
      }

      _selectedChatTitle = normalizedName;
      _currentKommSubView = 'active_chat';
    });
  }

  Map<String, String> _buildPrivatChatPreview(
    String chatName, {
    String fallback = 'Privatchat',
  }) {
    final chatMessages = _messages.where((m) => m['chat'] == chatName).toList();
    if (chatMessages.isEmpty) {
      return {'text': fallback, 'time': ''};
    }

    final last = chatMessages.last;
    final sender = last['sender']?.toString().trim() ?? '';
    final text = last['text']?.toString().trim() ?? '';
    final time = last['time']?.toString().trim() ?? '';

    final preview = sender.isEmpty
        ? text
        : sender == 'Du (Account)'
        ? 'Du: $text'
        : '$sender: $text';

    return {'text': preview.isNotEmpty ? preview : fallback, 'time': time};
  }

  Widget _buildKommOverview() {
    final kontaktListe =
        _teamMitglieder
            .where((mitglied) => _resolveWhatsAppNummer(mitglied).isNotEmpty)
            .toList()
          ..sort((a, b) {
            final nameA = (a['name'] as String? ?? '').toLowerCase();
            final nameB = (b['name'] as String? ?? '').toLowerCase();
            return nameA.compareTo(nameB);
          });

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          tr('communication'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          tr('communication_desc'),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 20),
        _buildCategoryKlickCard(
          tr('team_chat'),
          tr('team_chat_desc'),
          Icons.forum,
          Colors.blueAccent,
          () => setState(() => _currentKommSubView = 'chats'),
        ),
        _buildCategoryKlickCard(
          tr('notes'),
          tr('notes_desc'),
          Icons.comment,
          Colors.orangeAccent,
          () => setState(() => _currentKommSubView = 'anmerkungen'),
        ),
        _buildCategoryKlickCard(
          tr('votes'),
          tr('votes_desc'),
          Icons.how_to_vote,
          Colors.greenAccent,
          () => setState(() => _currentKommSubView = 'abstimmungen'),
        ),
        const SizedBox(height: 20),
        _buildWhatsAppDirectKontaktSection(kontaktListe),
        const SizedBox(height: 16),
        _buildWhatsAppBroadcastSection(),
      ],
    );
  }

  Widget _buildWhatsAppDirectKontaktSection(
    List<Map<String, dynamic>> kontaktListe,
  ) {
    return Card(
      color: kCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.quick_contacts_dialer, color: _kWhatsAppColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mitglieder-Direktkontakt',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Spieler und Eltern per WhatsApp direkt erreichen.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            if (kontaktListe.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Keine WhatsApp-Kontakte im aktuellen Team hinterlegt.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...kontaktListe.map((mitglied) {
                final name = mitglied['name']?.toString() ?? 'Mitglied';
                final rolle = mitglied['rolle']?.toString() ?? 'Kontakt';
                final eltern = mitglied['elternname']?.toString() ?? '';
                final nummer = _resolveWhatsAppNummer(mitglied);

                final subtitle = eltern.isNotEmpty && eltern != '-'
                    ? '$rolle • Eltern: $eltern'
                    : rolle;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: kDarkBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text(
                      '$subtitle\n$nummer',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    trailing: Material(
                      color: Colors.transparent,
                      child: Ink(
                        decoration: const ShapeDecoration(
                          color: _kWhatsAppColor,
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          tooltip: 'In WhatsApp schreiben',
                          icon: const Icon(Icons.chat, color: Colors.white),
                          onPressed: () => _openWhatsAppForMitglied(mitglied),
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppBroadcastSection() {
    final isTrainerTeam = _hasAnyRole(_kBroadcastAllowedRoles);
    final groupInvite =
        (_selectedTeam['whatsappGroupInvite'] as String?)?.trim() ?? '';
    final groupId = (_selectedTeam['whatsappGroupId'] as String?)?.trim() ?? '';
    final hasConfiguredTarget = groupInvite.isNotEmpty || groupId.isNotEmpty;

    return Card(
      color: kCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.campaign, color: Color(0xFF34D399)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Gruppen-Broadcast',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                if (isTrainerTeam)
                  TextButton.icon(
                    onPressed: _showWhatsAppGroupSetupDialog,
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Setup'),
                    style: TextButton.styleFrom(
                      foregroundColor: _kWhatsAppColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isTrainerTeam
                  ? 'Sende eine vorbereitete WhatsApp-Nachricht an die $_selectedTeamName Gruppe.'
                  : 'Nur Trainerteam und Vereinsadministratoren koennen Gruppen-Broadcasts versenden.',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            if (isTrainerTeam) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: kDarkBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasConfiguredTarget
                          ? Icons.check_circle
                          : Icons.info_outline,
                      color: hasConfiguredTarget
                          ? Colors.greenAccent
                          : Colors.amberAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasConfiguredTarget
                            ? 'Gruppenziel hinterlegt${groupInvite.isNotEmpty ? ' (Einladungslink aktiv)' : ''}.'
                            : 'Kein Gruppenziel hinterlegt. Broadcast nutzt Kontaktwahl mit vorbereitetem Text.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _whatsAppBroadcastController,
              enabled: isTrainerTeam,
              minLines: 3,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nachricht fuer die C-Jugend Gruppe eingeben...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: kDarkBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: _kWhatsAppColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kWhatsAppColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isTrainerTeam ? _sendWhatsAppBroadcast : null,
                icon: const Icon(Icons.send),
                label: const Text(
                  'An C-Jugend Gruppe senden',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsSubView() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentKommSubView = 'overview'),
        ),
        title: Text(
          tr('channels_chats'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildChatTile(
            'Trainerchat',
            'Nur Trainer, Co-Trainer & Betreuer',
            Icons.security,
            Colors.redAccent,
          ),
          _buildChatTile(
            'Elternchat',
            'Alle Eltern + Trainer & Betreuer',
            Icons.family_restroom,
            Colors.amber,
          ),
          _buildChatTile(
            'Spielerchat',
            'Trainer & Spieler',
            Icons.sports_soccer,
            Colors.green,
          ),
          _buildChatTile(
            'Allgemeiner Chat',
            'Komplette Mannschaft (Alle drin)',
            Icons.groups,
            Colors.blueAccent,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
            child: Text(
              tr('private_chats'),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_aktivePrivatChats.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                tr('no_private_chats'),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ..._aktivePrivatChats.map((chat) {
            final name = chat['name']?.toString() ?? 'Unbekannt';
            final fallback = chat['subtitle']?.toString() ?? 'Privatchat';
            final preview = _buildPrivatChatPreview(name, fallback: fallback);
            return _buildChatTile(
              name,
              preview['text'] ?? fallback,
              Icons.person,
              Colors.cyan,
              trailingLabel: preview['time'] ?? '',
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        onPressed: () => setState(() {
          _chatMemberSearch = '';
          _currentKommSubView = 'new_chat_select';
        }),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildActiveChatScreen() {
    final chatMessages = _messages
        .where((m) => m['chat'] == _selectedChatTitle)
        .toList();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kDarkBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentKommSubView = 'chats'),
        ),
        title: Text(
          _selectedChatTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatMessages.isEmpty
                ? Center(
                    child: Text(
                      tr('no_messages_chat'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: chatMessages.length,
                    itemBuilder: (context, index) {
                      final msg = chatMessages[index];
                      bool isMe = msg['sender'] == 'Du (Account)';
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? kPrimaryColor : kCardColor,
                            borderRadius: BorderRadius.circular(12).copyWith(
                              bottomRight: isMe
                                  ? const Radius.circular(0)
                                  : const Radius.circular(12),
                              topLeft: isMe
                                  ? const Radius.circular(12)
                                  : const Radius.circular(0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isMe)
                                Text(
                                  msg['sender'],
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                msg['text'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg['time'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: kDarkBackground,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatInputController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: tr(
                        'message_to',
                      ).replaceAll('{name}', _selectedChatTitle),
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: kPrimaryColor),
                  onPressed: () {
                    if (_chatInputController.text.trim().isEmpty) return;
                    setState(() {
                      _messages.add({
                        'chat': _selectedChatTitle,
                        'sender': 'Du (Account)',
                        'text': _chatInputController.text.trim(),
                        'time':
                            '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} Uhr',
                      });

                      final privatIndex = _aktivePrivatChats.indexWhere(
                        (c) =>
                            (c['name']?.toString().trim().toLowerCase() ??
                                '') ==
                            _selectedChatTitle.trim().toLowerCase(),
                      );
                      if (privatIndex > 0) {
                        final activeChat = _aktivePrivatChats.removeAt(
                          privatIndex,
                        );
                        _aktivePrivatChats.insert(0, activeChat);
                      }

                      _chatInputController.clear();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewChatSelectSubView() {
    final filteredMembers = _chatAuswahlMitglieder
        .where(
          (name) =>
              name.toLowerCase().contains(_chatMemberSearch.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentKommSubView = 'chats'),
        ),
        title: Text(
          tr('new_private_chat'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: (value) => setState(() => _chatMemberSearch = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: tr('search_member'),
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: kCardColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: kBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kPrimaryColor),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredMembers.isEmpty
                ? Center(
                    child: Text(
                      tr('no_member_found'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredMembers.length,
                    itemBuilder: (context, index) {
                      final name = filteredMembers[index];
                      final exists = _aktivePrivatChats.any(
                        (c) =>
                            (c['name']?.toString().trim().toLowerCase() ??
                                '') ==
                            name.toLowerCase(),
                      );

                      return Card(
                        color: kCardColor,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: kPrimaryColor.withValues(
                              alpha: 0.22,
                            ),
                            child: Text(
                              name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            exists
                                ? tr('private_chat_exists')
                                : tr('create_private_chat'),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                          onTap: () => _openOrCreatePrivatChat(name),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnmerkungenSubView() {
    bool darfAnmerkungenSehen = _hasAnyRole(const [
      'Vereinsadministrator',
      'Trainer',
      'Co-Trainer',
    ]);
    if (!darfAnmerkungenSehen) {
      return _buildRechteGesperrtSeite(tr('note_access_denied'));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentKommSubView = 'overview'),
        ),
        title: Text(tr('notes_box'), style: const TextStyle(fontSize: 17)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                minimumSize: const Size.fromHeight(45),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(tr('submit_note')),
              onPressed: () => _showAnmerkungErstellenDialog(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _eingereichteAnmerkungen.length,
              itemBuilder: (context, index) {
                final item = _eingereichteAnmerkungen[index];
                return Card(
                  color: kCardColor,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      Icons.feedback,
                      color: item['anonym']
                          ? Colors.redAccent
                          : Colors.orangeAccent,
                    ),
                    title: Text(
                      item['kategorie'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        item['text'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    trailing: Text(
                      item['autor'],
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: item['anonym'] ? Colors.redAccent : Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbstimmungenSubView() {
    bool kannAbstimmungErstellen = _hasAnyRole(const [
      'Vereinsadministrator',
      'Trainer',
      'Co-Trainer',
      'Betreuer',
    ]);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentKommSubView = 'overview'),
        ),
        title: Text(tr('votes'), style: const TextStyle(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (kannAbstimmungErstellen)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(45),
              ),
              icon: const Icon(Icons.playlist_add),
              label: Text(tr('new_vote_start')),
              onPressed: () => _showAbstimmungErstellenDialog(),
            ),
          const SizedBox(height: 16),
          ..._aktiveAbstimmungen.map((voting) {
            final int votingId = (voting['id'] as int?) ?? voting.hashCode;
            final bool allowMultipleAnswers =
                voting['allowMultipleAnswers'] == true;
            final List<Map<String, dynamic>> optionen =
                (voting['optionen'] as List).cast<Map<String, dynamic>>();
            final int gesamtStimmen = optionen.fold<int>(
              0,
              (sum, opt) => sum + ((opt['stimmen'] as num?)?.toInt() ?? 0),
            );
            final Set<int> aktuelleAuswahl = _abstimmungsAuswahl.putIfAbsent(
              votingId,
              () => <int>{},
            );

            return Card(
              color: kCardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          voting['voted'] == true
                              ? '✓ ${tr('voted_status')}'
                              : '◷ ${tr('open_status')}',
                          style: TextStyle(
                            color: voting['voted'] == true
                                ? Colors.blue
                                : Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${tr('target_group')}: ${voting['zielgruppe']}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      voting['titel'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...optionen.asMap().entries.map((entry) {
                      final index = entry.key;
                      final opt = entry.value;
                      final int stimmen =
                          (opt['stimmen'] as num?)?.toInt() ?? 0;
                      final double prozent = gesamtStimmen == 0
                          ? 0.0
                          : stimmen / gesamtStimmen;
                      final bool selected = aktuelleAuswahl.contains(index);

                      if (!allowMultipleAnswers) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: GestureDetector(
                            onTap: voting['voted'] == true
                                ? null
                                : () {
                                    setState(() {
                                      opt['stimmen'] =
                                          ((opt['stimmen'] as num?)?.toInt() ??
                                              0) +
                                          1;
                                      voting['voted'] = true;
                                    });
                                  },
                            child: Stack(
                              children: [
                                Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: kDarkBackground,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                if (voting['voted'] == true)
                                  FractionallySizedBox(
                                    widthFactor: prozent,
                                    child: Container(
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: kPrimaryColor.withAlpha(90),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                Container(
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        opt['text'] as String,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      if (voting['voted'] == true)
                                        Text(
                                          '${(prozent * 100).toInt()}% (${opt['stimmen']})',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: InkWell(
                          onTap: voting['voted'] == true
                              ? null
                              : () {
                                  setState(() {
                                    if (selected) {
                                      aktuelleAuswahl.remove(index);
                                    } else {
                                      aktuelleAuswahl.add(index);
                                    }
                                  });
                                },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? kPrimaryColor.withValues(alpha: 0.18)
                                  : kDarkBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? kPrimaryColor : kBorderColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: selected ? Colors.white : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    opt['text'] as String,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                if (voting['voted'] == true)
                                  Text(
                                    '${(prozent * 100).toInt()}% (${opt['stimmen']})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (allowMultipleAnswers && voting['voted'] != true) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: aktuelleAuswahl.isEmpty
                              ? null
                              : () {
                                  setState(() {
                                    for (final index in aktuelleAuswahl) {
                                      optionen[index]['stimmen'] =
                                          ((optionen[index]['stimmen'] as num?)
                                                  ?.toInt() ??
                                              0) +
                                          1;
                                    }
                                    voting['voted'] = true;
                                  });
                                  aktuelleAuswahl.clear();
                                },
                          icon: const Icon(Icons.how_to_vote),
                          label: const Text('Stimme abgeben'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<dynamic>? runtimeCastList(dynamic p) => p as List<dynamic>?;

  Widget _buildChatTile(
    String titel,
    String sub,
    IconData icon,
    Color farbe, {
    String trailingLabel = '',
  }) {
    return Card(
      color: kCardColor,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: farbe.withAlpha(30),
          child: Icon(icon, color: farbe, size: 20),
        ),
        title: Text(
          titel,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: trailingLabel.isEmpty
            ? const Icon(Icons.chevron_right, color: Colors.grey)
            : SizedBox(
                width: 56,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trailingLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 2),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ],
                ),
              ),
        onTap: () {
          setState(() {
            _selectedChatTitle = titel;
            _currentKommSubView = 'active_chat';
          });
        },
      ),
    );
  }

  void _showAnmerkungErstellenDialog() {
    final textController = TextEditingController();
    String gewaehlteKat = 'Anmerkung zum Training';
    bool anonym = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: kCardColor,
          title: Text(tr('submit_note_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: gewaehlteKat,
                isExpanded: true,
                dropdownColor: kCardColor,
                items:
                    [
                          'Anmerkung zum Training',
                          'Probleme',
                          'Spiele',
                          'Management',
                          'Spieler',
                        ]
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                onChanged: (v) => setDlgState(() => gewaehlteKat = v!),
              ),
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: InputDecoration(hintText: tr('note_hint')),
              ),
              Row(
                children: [
                  Checkbox(
                    value: anonym,
                    onChanged: (v) => setDlgState(() => anonym = v!),
                  ),
                  Text(tr('submit_anonymous')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () {
                if (textController.text.trim().isEmpty) return;
                setState(() {
                  _eingereichteAnmerkungen.insert(0, {
                    'kategorie': gewaehlteKat,
                    'text': textController.text.trim(),
                    'anonym': anonym,
                    'autor': anonym ? 'Anonym' : 'Du (Account)',
                  });
                });
                Navigator.pop(context);
              },
              child: Text(tr('send')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAbstimmungErstellenDialog() async {
    await showDialog(
      context: context,
      builder: (context) => _AbstimmungErstellenDialog(
        onCreate: (titel, allowMultipleAnswers, optionen) {
          setState(() {
            _aktiveAbstimmungen.insert(0, {
              'id': DateTime.now().millisecondsSinceEpoch,
              'titel': titel,
              'zielgruppe': 'Alle',
              'allowMultipleAnswers': allowMultipleAnswers,
              'optionen': optionen,
              'voted': false,
            });
          });
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SEITE 2: TEAM (VERTEILER-LOGIK)
  // ─────────────────────────────────────────────────────────────────
  Widget _buildTeamBody() {
    switch (_currentTeamSubView) {
      case 'kasse':
        return _buildTeamKasseSubView();
      case 'regeln':
        return _buildTeamRegelnSubView();
      case 'statistik':
        return _buildTeamStatistikSubView();
      case 'beteiligungs_analyse':
        return _buildTeamBeteiligungsAnalyseView();
      case 'mitglieder_liste':
        return _buildTeamMitgliederSubView();
      case 'karten':
        return CardsTableScreen(
          userRole: _currentUserRole,
          currentUserName: _currentUserName,
        );
      case 'uebersicht':
      case 'overview':
      default:
        return _buildTeamOverview();
    }
  }

  List<Map<String, dynamic>> _currentTeamMembers() {
    final raw = (_selectedTeam['mitglieder'] as List?) ?? <dynamic>[];
    final members = raw.whereType<Map<String, dynamic>>().toList();
    members.sort((a, b) {
      const order = <String, int>{
        'Spieler': 0,
        'Trainer': 1,
        'Co-Trainer': 2,
        'Betreuer': 3,
        'Vereinsadministrator': 4,
      };
      final aOrder = order[a['rolle']?.toString() ?? ''] ?? 99;
      final bOrder = order[b['rolle']?.toString() ?? ''] ?? 99;
      final roleCompare = aOrder.compareTo(bOrder);
      if (roleCompare != 0) return roleCompare;
      return (a['name']?.toString() ?? '').compareTo(
        b['name']?.toString() ?? '',
      );
    });
    return members;
  }

  Map<String, dynamic>? _findTeamMember(String name) {
    final normalized = name.trim();
    final raw = (_selectedTeam['mitglieder'] as List?) ?? <dynamic>[];
    for (final entry in raw.whereType<Map<String, dynamic>>()) {
      if ((entry['name']?.toString() ?? '') == normalized) {
        return entry;
      }
    }
    for (final member in _vereinsMitglieder) {
      if ((member['name']?.toString() ?? '') == normalized) {
        return member;
      }
    }
    return null;
  }

  Map<String, dynamic>? _selectedUserProfileForCurrentTeam() {
    return _findTeamMember(_currentUserName);
  }

  bool get _canEditScorecard {
    final userRoles = _currentUserRoles;
    return userRoles.contains('Trainer') ||
        userRoles.contains('Co-Trainer') ||
        userRoles.contains('Vereinsadministrator');
  }

  bool _isPlayerProfile(Map<String, dynamic>? profile) {
    return (profile?['rolle']?.toString() ?? '') == 'Spieler';
  }

  bool _canViewOwnScorecardInPersonalBody(Map<String, dynamic>? profile) {
    if (profile == null) return false;
    if (!_isPlayerProfile(profile)) return false;
    if ((profile['name']?.toString() ?? '') != _currentUserName) return false;
    return _currentUserRoles.contains('Spieler');
  }

  Map<String, dynamic> _buildDefaultScorecard() {
    return {
      'technik': 65,
      'taktik': 58,
      'fitness': 70,
      'mental': 75,
      'notizen':
          'Sehr trainingsfleissig, starker linker Fuss. Muss am Stellungsspiel arbeiten.',
      'letztesUpdate': '28.06.2026',
    };
  }

  int _scoreValueFrom(dynamic value, int fallback) {
    final parsed = value is num ? value.toInt() : int.tryParse('$value');
    if (parsed == null) return fallback;
    return parsed.clamp(1, 99);
  }

  Map<String, dynamic> _normalizedScorecard(Map<String, dynamic>? raw) {
    final source = raw ?? _buildDefaultScorecard();
    return {
      'technik': _scoreValueFrom(source['technik'], 50),
      'taktik': _scoreValueFrom(source['taktik'], 50),
      'fitness': _scoreValueFrom(source['fitness'], 50),
      'mental': _scoreValueFrom(source['mental'], 50),
      'notizen': (source['notizen']?.toString() ?? '').trim(),
      'letztesUpdate': (source['letztesUpdate']?.toString() ?? '28.06.2026')
          .trim(),
    };
  }

  void _ensureScorecardsInTeamMembers() {
    for (final member in _vereinsMitglieder) {
      if ((member['rolle']?.toString() ?? '') != 'Spieler') continue;
      member['scorecard'] = _normalizedScorecard(
        member['scorecard'] as Map<String, dynamic>?,
      );
    }

    for (final team in _vereinsTeams) {
      final members = (team['mitglieder'] as List?) ?? <dynamic>[];
      for (final entry in members.whereType<Map<String, dynamic>>()) {
        if ((entry['rolle']?.toString() ?? '') != 'Spieler') continue;
        entry['scorecard'] = _normalizedScorecard(
          entry['scorecard'] as Map<String, dynamic>?,
        );
      }
    }
  }

  Color _scoreColor(int value) {
    if (value >= 75) return Colors.greenAccent;
    if (value >= 55) return Colors.amberAccent;
    return Colors.deepOrangeAccent;
  }

  Widget _buildScoreTile(String title, int value) {
    final color = _scoreColor(value);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kDarkBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '$value',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.white10),
                  FractionallySizedBox(
                    widthFactor: value / 100,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.75), color],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorecardSection(
    Map<String, dynamic>? profile, {
    required bool canEditScorecard,
  }) {
    if (!_isPlayerProfile(profile)) {
      return const SizedBox.shrink();
    }

    final scorecard = _normalizedScorecard(
      profile?['scorecard'] as Map<String, dynamic>?,
    );

    final technik = _scoreValueFrom(scorecard['technik'], 65);
    final taktik = _scoreValueFrom(scorecard['taktik'], 58);
    final fitness = _scoreValueFrom(scorecard['fitness'], 70);
    final mental = _scoreValueFrom(scorecard['mental'], 75);
    final notes = scorecard['notizen']?.toString() ?? '';
    final update = scorecard['letztesUpdate']?.toString() ?? '-';

    return Card(
      color: kCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Leistungs-Scorecard',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                if (canEditScorecard)
                  OutlinedButton.icon(
                    onPressed: () => _showEditScorecardDialog(
                      profile,
                      canEditScorecard: canEditScorecard,
                    ),
                    icon: const Icon(Icons.tune, size: 16),
                    label: const Text('Scorecard aktualisieren'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.55,
              children: [
                _buildScoreTile('Technik', technik),
                _buildScoreTile('Taktik', taktik),
                _buildScoreTile('Fitness', fitness),
                _buildScoreTile('Mental', mental),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Letztes Update: $update',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kDarkBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                notes.isEmpty ? '-' : notes,
                style: const TextStyle(height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditScorecardDialog(
    Map<String, dynamic>? profile, {
    required bool canEditScorecard,
  }) async {
    if (!canEditScorecard || profile == null) return;
    final role = profile['rolle']?.toString() ?? '';
    if (role != 'Spieler') return;

    final current = _normalizedScorecard(
      profile['scorecard'] as Map<String, dynamic>?,
    );
    double technik = _scoreValueFrom(current['technik'], 65).toDouble();
    double taktik = _scoreValueFrom(current['taktik'], 58).toDouble();
    double fitness = _scoreValueFrom(current['fitness'], 70).toDouble();
    double mental = _scoreValueFrom(current['mental'], 75).toDouble();
    final notesController = TextEditingController(
      text: current['notizen']?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: kCardColor,
          title: const Text('Leistungs-Scorecard bearbeiten'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Technik: ${technik.round()}'),
                  Slider(
                    value: technik,
                    min: 1,
                    max: 99,
                    divisions: 98,
                    label: technik.round().toString(),
                    onChanged: (value) => setDialogState(() => technik = value),
                  ),
                  Text('Taktik: ${taktik.round()}'),
                  Slider(
                    value: taktik,
                    min: 1,
                    max: 99,
                    divisions: 98,
                    label: taktik.round().toString(),
                    onChanged: (value) => setDialogState(() => taktik = value),
                  ),
                  Text('Fitness: ${fitness.round()}'),
                  Slider(
                    value: fitness,
                    min: 1,
                    max: 99,
                    divisions: 98,
                    label: fitness.round().toString(),
                    onChanged: (value) => setDialogState(() => fitness = value),
                  ),
                  Text('Mental: ${mental.round()}'),
                  Slider(
                    value: mental,
                    min: 1,
                    max: 99,
                    divisions: 98,
                    label: mental.round().toString(),
                    onChanged: (value) => setDialogState(() => mental = value),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Sportliche Notizen',
                      hintText: 'Beobachtungen nach Spiel oder Training',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () {
                final updated = {
                  'technik': technik.round(),
                  'taktik': taktik.round(),
                  'fitness': fitness.round(),
                  'mental': mental.round(),
                  'notizen': notesController.text.trim(),
                  'letztesUpdate': _formatTodayForList(),
                };
                setState(() {
                  profile['scorecard'] = updated;
                });
                Navigator.pop(context);
              },
              child: Text(tr('save')),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? _playerStatisticsForCurrentUser() {
    for (final stat in _spielerStatistiken) {
      if ((stat['name']?.toString() ?? '') == _currentUserName) {
        return stat;
      }
    }
    return null;
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final normalized = phoneNumber.trim();
    if (normalized.isEmpty || normalized == '-') return;
    final uri = Uri.parse(
      'tel:${normalized.replaceAll(RegExp(r'[^0-9+]'), '')}',
    );
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _updateTeamMember(
    Map<String, dynamic> original,
    Map<String, dynamic> updated,
  ) {
    setState(() {
      final teamMembers = (_selectedTeam['mitglieder'] as List?) ?? <dynamic>[];
      final teamIndex = teamMembers.indexOf(original);
      if (teamIndex >= 0) {
        teamMembers[teamIndex] = updated;
      }

      final globalIndex = _vereinsMitglieder.indexWhere(
        (member) =>
            (member['name']?.toString() ?? '') ==
            (original['name']?.toString() ?? ''),
      );
      if (globalIndex >= 0) {
        final existing = _vereinsMitglieder[globalIndex];
        existing['rolle'] = updated['rolle'] ?? existing['rolle'];
        existing['phone'] = updated['notfallTelefon'] ?? existing['phone'];
      }
    });
    if (widget.onAuthDataChanged != null) {
      unawaited(widget.onAuthDataChanged!.call());
    }
  }

  Future<void> _showEditTeamMemberDialog(Map<String, dynamic> member) async {
    if (!_isCoachOrAdmin) return;

    final nameController = TextEditingController(
      text: member['name']?.toString() ?? '',
    );
    final selectedRoles = <String>{
      ...(((member['rollen'] as List?) ?? <dynamic>[])
          .map((e) => e.toString())
          .where((role) => role.trim().isNotEmpty)),
    };
    if (selectedRoles.isEmpty) {
      final fallbackRole = member['rolle']?.toString().trim() ?? '';
      if (fallbackRole.isNotEmpty) {
        selectedRoles.add(fallbackRole);
      } else {
        selectedRoles.add('Spieler');
      }
    }
    final teamIds = <String>{
      ...(((member['erlaubteTeams'] as List?) ?? <dynamic>[]).map(
        (e) => e.toString(),
      )),
    };
    final phoneController = TextEditingController(
      text:
          member['notfallTelefon']?.toString() ??
          member['phone']?.toString() ??
          '-',
    );
    const rollen = [
      'Spieler',
      'Betreuer',
      'Co-Trainer',
      'Trainer',
      'Vereinsadministrator',
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: kCardColor,
          title: Text('Mitglied bearbeiten'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rollen',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...rollen.map((role) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: selectedRoles.contains(role),
                      title: Text(role),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            selectedRoles.add(role);
                          } else {
                            selectedRoles.remove(role);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Notfall-Telefon',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._vereinsTeams.map((team) {
                    final teamId = team['id'] as String;
                    final teamName = (team['name'] as String?) ?? teamId;
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: teamIds.contains(teamId),
                      title: Text(teamName),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            teamIds.add(teamId);
                          } else {
                            teamIds.remove(teamId);
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () {
                final normalizedRoles = rollen
                    .where(selectedRoles.contains)
                    .toList();
                if (normalizedRoles.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bitte mindestens eine Rolle auswählen.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
                final updated = Map<String, dynamic>.from(member)
                  ..['name'] = nameController.text.trim().isEmpty
                      ? member['name']
                      : nameController.text.trim()
                  ..['rolle'] = normalizedRoles.first
                  ..['rollen'] = normalizedRoles
                  ..['notfallTelefon'] = phoneController.text.trim()
                  ..['phone'] = phoneController.text.trim()
                  ..['erlaubteTeams'] =
                      normalizedRoles.contains('Vereinsadministrator')
                      ? <String>['all']
                      : teamIds.toList();
                _updateTeamMember(member, updated);
                Navigator.pop(context);
              },
              child: Text(tr('save')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamOverview() {
    final List<Map<String, dynamic>> topScorer = List.from(_spielerStatistiken);
    int scoreValue(Map<String, dynamic> row) {
      final tore = (row['tore'] as num?)?.toInt() ?? 0;
      final vorlagen = (row['vorlagen'] as num?)?.toInt() ?? 0;
      return tore + vorlagen;
    }

    topScorer.sort((a, b) => scoreValue(b).compareTo(scoreValue(a)));
    final String topScorerValue = topScorer.isEmpty
        ? '-'
        : '${topScorer.first['name']} (${topScorer.first['tore']} T / ${topScorer.first['vorlagen']} V)';

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth > 900
            ? (constraints.maxWidth - 64) / 3
            : constraints.maxWidth > 600
            ? (constraints.maxWidth - 56) / 2
            : constraints.maxWidth;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              tr('team_center'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              tr('squad_admin_finance'),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            // Team Photo Banner
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: const DecorationImage(
                  image: AssetImage('lib/assets/Mannschaftsfoto_c_jugend.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_vorbereitungsDateien.isNotEmpty || _canManageVorbereitung) ...[
              const SizedBox(height: 14),
              Card(
                color: kCardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Colors.white10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Angehefteter Vorbereitungsplan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      if (_vorbereitungsDateien.isEmpty)
                        const Text(
                          'Noch keine PDF/XLSX-Datei hochgeladen.',
                          style: TextStyle(color: Colors.white70),
                        )
                      else
                        ..._vorbereitungsDateien.map((file) {
                          final name = file['name']?.toString() ?? 'Datei';
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(name),
                            trailing: const Icon(Icons.download),
                            onTap: () => _openVorbereitungsDatei(file),
                          );
                        }),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => setState(
                              () => _currentTerminSubView =
                                  'vorbereitung_overview',
                            ),
                            icon: const Icon(Icons.visibility),
                            label: const Text('Vorbereitungszentrale'),
                          ),
                          if (_canManageVorbereitung)
                            OutlinedButton.icon(
                              onPressed: _pickVorbereitungsDatei,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('PDF/XLSX hochladen'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildTeamOverviewStatCard(
                  width: cardWidth,
                  icon: Icons.savings,
                  title: tr('cash_status'),
                  value:
                      '${(_kassenTransaktionen.fold<double>(0.0, (sum, item) => sum + ((item['betrag'] as num?)?.toDouble() ?? 0.0))).toStringAsFixed(2).replaceAll('.', ',')} €',
                  color: Colors.amber,
                ),
                _buildTeamOverviewStatCard(
                  width: cardWidth,
                  icon: Icons.gavel,
                  title: tr('rules'),
                  value: tr(
                    'entries_count',
                  ).replaceAll('{count}', _strafenKatalog.length.toString()),
                  color: Colors.redAccent,
                ),
                _buildTeamOverviewStatCard(
                  width: cardWidth,
                  icon: Icons.star,
                  title: tr('top_scorer'),
                  value: topScorerValue,
                  color: Colors.tealAccent,
                ),
                _buildTeamOverviewStatCard(
                  width: cardWidth,
                  icon: Icons.assignment,
                  title: tr('cards'),
                  value: tr('yellow_red_cards')
                      .replaceAll(
                        '{yellow}',
                        _kartenUebersicht
                            .fold<int>(
                              0,
                              (sum, item) =>
                                  sum + ((item['gelb'] as num?)?.toInt() ?? 0),
                            )
                            .toString(),
                      )
                      .replaceAll(
                        '{red}',
                        _kartenUebersicht
                            .fold<int>(
                              0,
                              (sum, item) =>
                                  sum + ((item['rot'] as num?)?.toInt() ?? 0),
                            )
                            .toString(),
                      ),
                  color: Colors.orangeAccent,
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, buttonConstraints) {
                if (buttonConstraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTeamSwitchButton(
                          tr('team_cash'),
                          Icons.savings,
                          Colors.amber,
                          'kasse',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTeamSwitchButton(
                          tr('statistics'),
                          Icons.analytics,
                          Colors.tealAccent,
                          'statistik',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTeamSwitchButton(
                          'Mitglieder',
                          Icons.groups,
                          Colors.pinkAccent,
                          'mitglieder_liste',
                        ),
                      ),
                    ],
                  );
                }
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildTeamSwitchButton(
                      tr('team_cash'),
                      Icons.savings,
                      Colors.amber,
                      'kasse',
                    ),
                    _buildTeamSwitchButton(
                      tr('statistics'),
                      Icons.analytics,
                      Colors.tealAccent,
                      'statistik',
                    ),
                    _buildTeamSwitchButton(
                      'Mitglieder',
                      Icons.groups,
                      Colors.pinkAccent,
                      'mitglieder_liste',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildCategoryKlickCard(
                    tr('team_cash'),
                    tr('team_cash_desc'),
                    Icons.savings,
                    Colors.amber,
                    () => setState(() => _currentTeamSubView = 'kasse'),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildCategoryKlickCard(
                    tr('statistics'),
                    tr('statistics_desc'),
                    Icons.analytics,
                    Colors.tealAccent,
                    () => setState(() => _currentTeamSubView = 'statistik'),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildCategoryKlickCard(
                    'Mitglieder / Kaderliste',
                    'Alle Spieler, Trainer und Betreuer im aktuellen Team.',
                    Icons.groups,
                    Colors.pinkAccent,
                    () => setState(
                      () => _currentTeamSubView = 'mitglieder_liste',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildPersonalBody() {
    final double debt = _currentUserDebt();
    final bool isDebtOpen = debt > 0.0;
    final Map<String, dynamic>? profile = _selectedUserProfileForCurrentTeam();
    final Map<String, dynamic>? stats = _playerStatisticsForCurrentUser();
    final int goals = (stats?['tore'] as int?) ?? 0;
    final int assists = (stats?['vorlagen'] as int?) ?? 0;
    final int trainingParticipation =
        (stats?['trainingsbeteiligung'] as int?) ?? 0;
    final bool canViewOwnScorecard = _canViewOwnScorecardInPersonalBody(
      profile,
    );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          tr('profile_title'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tr('own_account'),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 18),
        Card(
          color: kCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white10),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: kPrimaryColor.withValues(alpha: 0.2),
              child: Text(
                _currentUserName.isNotEmpty
                    ? _currentUserName.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              '$_currentUserName (${tr('own_account')})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Rollen', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _currentUserRoles.map((role) {
                    final color = role == 'Vereinsadministrator'
                        ? Colors.amberAccent
                        : role == 'Trainer'
                        ? Colors.lightBlueAccent
                        : role == 'Co-Trainer'
                        ? Colors.tealAccent
                        : role == 'Betreuer'
                        ? Colors.orangeAccent
                        : Colors.greenAccent;
                    return Chip(
                      label: Text(
                        role,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: color.withValues(alpha: 0.22),
                      side: BorderSide(color: color.withValues(alpha: 0.55)),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildTeamOverviewStatCard(
              width: 280,
              icon: Icons.account_balance_wallet,
              title: tr('open_team_cash'),
              value: '${debt.toStringAsFixed(2).replaceAll('.', ',')} €',
              color: isDebtOpen ? Colors.redAccent : Colors.greenAccent,
            ),
            _buildTeamOverviewStatCard(
              width: 280,
              icon: Icons.calendar_month,
              title: tr('next_7_days'),
              value: tr('appointments_count').replaceAll(
                '{count}',
                _getTermineIndicesNextWeek().length.toString(),
              ),
              color: Colors.blueAccent,
            ),
            _buildTeamOverviewStatCard(
              width: 280,
              icon: Icons.how_to_vote,
              title: tr('open_votes'),
              value: '${_getOpenAbstimmungenCount()}',
              color: Colors.purpleAccent,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Persönliche Leistungsdaten',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          color: kCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildProfileInfoChip(
                  'Rückennummer',
                  profile?['rueckennummer']?.toString() ?? '-',
                ),
                _buildProfileInfoChip(
                  'Starker Fuß',
                  profile?['starkerFuss']?.toString() ?? '-',
                ),
                _buildProfileInfoChip(
                  'Hauptposition',
                  profile?['hauptposition']?.toString() ?? '-',
                ),
                _buildProfileInfoChip(
                  'Nebenposition',
                  profile?['nebenposition']?.toString() ?? '-',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Notfallkontakte',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          color: kCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(
                  'Eltern',
                  profile?['elternname']?.toString() ?? '-',
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _launchPhoneCall(
                    profile?['notfallTelefon']?.toString() ??
                        profile?['phone']?.toString() ??
                        '-',
                  ),
                  child: _buildDetailRow(
                    'Notfall-Telefon',
                    profile?['notfallTelefon']?.toString() ??
                        profile?['phone']?.toString() ??
                        '-',
                    accent: Colors.amber,
                  ),
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  'Medizinische Hinweise',
                  profile?['medizinischeHinweise']?.toString() ?? '-',
                ),
              ],
            ),
          ),
        ),
        if (canViewOwnScorecard) ...[
          const SizedBox(height: 14),
          _buildScorecardSection(profile, canEditScorecard: false),
        ],
        const SizedBox(height: 14),
        Text(
          'Saison-Statistik',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildTeamOverviewStatCard(
              width: 200,
              icon: Icons.sports_soccer,
              title: 'Tore',
              value: goals.toString(),
              color: Colors.tealAccent,
            ),
            _buildTeamOverviewStatCard(
              width: 200,
              icon: Icons.assist_walker,
              title: 'Vorlagen',
              value: assists.toString(),
              color: Colors.orangeAccent,
            ),
            _buildTeamOverviewStatCard(
              width: 200,
              icon: Icons.calendar_month,
              title: 'Trainingsbeteiligung',
              value: '$trainingParticipation %',
              color: Colors.lightBlueAccent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileInfoChip(String label, String value) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kDarkBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color accent = Colors.white,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: TextStyle(color: accent, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTeamOverviewStatCard({
    double? width,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        color: kCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSwitchButton(
    String title,
    IconData icon,
    Color color,
    String targetView,
  ) {
    final bool selected = _currentTeamSubView == targetView;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? color : kCardColor,
        foregroundColor: selected ? Colors.black : Colors.white,
        side: BorderSide(color: selected ? color : Colors.white12),
      ),
      icon: Icon(icon, size: 18),
      label: Text(title),
      onPressed: () => setState(() => _currentTeamSubView = targetView),
    );
  }

  Widget _buildTeamKasseSubView() {
    final double kassenGuthaben = _kassenTransaktionen.fold(
      0.0,
      (sum, item) => sum + ((item['betrag'] as num?)?.toDouble() ?? 0.0),
    );

    final List<Map<String, dynamic>> offeneStrafen = _offeneStrafen
        .where((item) => item['offen'] == true)
        .toList();

    final List<Map<String, dynamic>> sichtbareOffeneStrafen = _isSpielerRole
        ? offeneStrafen
              .where(
                (item) =>
                    (item['spieler']?.toString().trim() ?? '') ==
                    _currentUserName,
              )
              .toList()
        : offeneStrafen;

    final double offeneStrafenSumme = sichtbareOffeneStrafen.fold(
      0.0,
      (sum, item) => sum + ((item['betrag'] as num?)?.toDouble() ?? 0.0),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentTeamSubView = 'uebersicht'),
        ),
        title: Text(
          tr('team_cash'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isCoachOrAdmin)
            IconButton(
              tooltip: 'Strafenkatalog öffnen',
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showStrafenkatalogQuickAccessDialog(),
            ),
          if (!_isSpielerRole)
            IconButton(
              tooltip: tr('players_overview'),
              icon: const Icon(Icons.groups),
              onPressed: _showSpielerStrafenUebersichtDialog,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => setState(() => _currentTeamSubView = 'regeln'),
              icon: const Icon(Icons.gavel),
              label: const Text(
                'Regeln / Strafenkatalog einsehen',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 360,
                child: _buildTeamOverviewStatCard(
                  icon: Icons.account_balance_wallet,
                  title: tr('cash_balance'),
                  value: _formatEuro(kassenGuthaben),
                  color: kassenGuthaben >= 0
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
              ),
              SizedBox(
                width: 360,
                child: _buildTeamOverviewStatCard(
                  icon: Icons.warning_amber,
                  title: _isSpielerRole
                      ? tr('my_open_fines')
                      : tr('pending_fines'),
                  value: _formatEuro(offeneStrafenSumme),
                  color: Colors.orangeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _isSpielerRole
                ? tr('open_fines_of').replaceAll('{name}', _currentUserName)
                : tr('open_sins_list'),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (_isCoachOrAdmin)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _showStrafenkatalogQuickAccessDialog(),
                icon: const Icon(Icons.tune),
                label: const Text('Strafenkatalog öffnen'),
              ),
            ),
          if (sichtbareOffeneStrafen.isEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                tr('no_open_fines'),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ...sichtbareOffeneStrafen.map((item) {
            return Card(
              color: kCardColor,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: _isCoachOrAdmin
                    ? () => _showStrafenkatalogQuickAccessDialog(
                        vorgewaehlterSpieler: item['spieler']?.toString(),
                      )
                    : null,
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                  child: Icon(
                    item['icon'] as IconData? ?? Icons.person,
                    color: Colors.redAccent,
                  ),
                ),
                title: Text(
                  item['spieler'] as String? ?? 'Unbekannt',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  item['grund'] as String? ?? '-',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatEuro(
                        ((item['betrag'] as num?)?.toDouble() ?? 0.0),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (_isCoachOrAdmin)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            final betrag =
                                ((item['betrag'] as num?)?.toDouble() ?? 0.0);
                            _offeneStrafen.remove(item);
                            _kassenTransaktionen.insert(0, {
                              'datum': _formatTodayForList(),
                              'spieler': item['spieler'] ?? 'Unbekannt',
                              'grund': item['grund'] ?? 'Strafe bezahlt',
                              'betrag': betrag,
                              'typ': 'Einnahme',
                            });
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: Text(tr('mark_paid')),
                      )
                    else
                      Text(
                        tr('open'),
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              tr('recent_transactions'),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._kassenTransaktionen.map((trans) {
            final betrag = (trans['betrag'] as num?)?.toDouble() ?? 0.0;
            final bool isEinnahme = betrag > 0;
            return Card(
              color: kCardColor,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isEinnahme
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  child: Icon(
                    isEinnahme ? Icons.add_circle : Icons.remove_circle,
                    color: isEinnahme ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(
                  trans['spieler'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${trans['datum']} • ${trans['grund']}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: Text(
                  '${isEinnahme ? '+' : ''}${betrag.toStringAsFixed(2).replaceAll('.', ',')} €',
                  style: TextStyle(
                    color: isEinnahme ? Colors.green : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: _isCoachOrAdmin
          ? FloatingActionButton(
              backgroundColor: kPrimaryColor,
              onPressed: _showStrafeVerhaengenDialog,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Future<void> _showStrafenkatalogQuickAccessDialog({
    String? vorgewaehlterSpieler,
  }) async {
    if (_strafenKatalog.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('fine_catalog_empty'))));
      return;
    }

    final spielerNamen =
        _spielerStatistiken
            .map((e) => e['name']?.toString() ?? '')
            .where((name) => name.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    if (spielerNamen.isEmpty) {
      spielerNamen.add(_currentUserName);
    }

    String selectedSpieler = spielerNamen.contains(vorgewaehlterSpieler)
        ? vorgewaehlterSpieler!
        : spielerNamen.first;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: kCardColor,
          title: const Row(
            children: [
              Icon(Icons.gavel, color: Colors.redAccent),
              SizedBox(width: 10),
              Text('Strafenkatalog'),
            ],
          ),
          content: SizedBox(
            width: 580,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buchung direkt aus dem Katalog starten',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSpieler,
                    dropdownColor: kCardColor,
                    decoration: const InputDecoration(
                      labelText: 'Spieler auswählen',
                    ),
                    items: spielerNamen
                        .map(
                          (name) => DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDlgState(() => selectedSpieler = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  ..._strafenKatalog.map((regel) {
                    return Card(
                      color: kDarkBackground,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          regel['icon'] as IconData,
                          color: Colors.redAccent,
                        ),
                        title: Text(
                          (regel['regel'] as String?) ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${(regel['strafe'] as num?)?.toDouble().toStringAsFixed(2).replaceAll('.', ',')} €',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showStrafeVerhaengenDialog(
                            initialSpieler: selectedSpieler,
                            initialRegel: regel,
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('cancel')),
            ),
          ],
        ),
      ),
    );
  }

  void _showSpielerStrafenUebersichtDialog() {
    final Map<String, Map<String, double>> summenProSpieler = {};

    for (final item in _offeneStrafen) {
      final String spieler = item['spieler'] as String? ?? 'Unbekannt';
      final double betrag = (item['betrag'] as num?)?.toDouble() ?? 0.0;
      final bool offen = item['offen'] == true;

      summenProSpieler.putIfAbsent(
        spieler,
        () => {'offen': 0.0, 'bezahlt': 0.0},
      );
      if (offen) {
        summenProSpieler[spieler]!['offen'] =
            (summenProSpieler[spieler]!['offen'] ?? 0.0) + betrag;
      } else {
        summenProSpieler[spieler]!['bezahlt'] =
            (summenProSpieler[spieler]!['bezahlt'] ?? 0.0) + betrag;
      }
    }

    final List<String> spielerNamen = summenProSpieler.keys.toList()..sort();
    final double gesamtOffen = summenProSpieler.values.fold(
      0.0,
      (sum, value) => sum + (value['offen'] ?? 0.0),
    );
    final double gesamtBezahlt = summenProSpieler.values.fold(
      0.0,
      (sum, value) => sum + (value['bezahlt'] ?? 0.0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: Row(
          children: [
            const Icon(Icons.groups, color: Colors.amber),
            const SizedBox(width: 10),
            Text(tr('fines_per_player')),
          ],
        ),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: kDarkBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('total_open').replaceAll(
                          '{value}',
                          gesamtOffen.toStringAsFixed(2).replaceAll('.', ','),
                        ),
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr('total_paid').replaceAll(
                          '{value}',
                          gesamtBezahlt.toStringAsFixed(2).replaceAll('.', ','),
                        ),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (spielerNamen.isEmpty)
                  Text(
                    tr('no_fines_yet'),
                    style: const TextStyle(color: Colors.grey),
                  )
                else
                  ...spielerNamen.map((name) {
                    final double offen =
                        summenProSpieler[name]!['offen'] ?? 0.0;
                    final double bezahlt =
                        summenProSpieler[name]!['bezahlt'] ?? 0.0;
                    final double gesamt = offen + bezahlt;

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kDarkBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                tr('open_amount').replaceAll(
                                  '{value}',
                                  offen.toStringAsFixed(2).replaceAll('.', ','),
                                ),
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                tr('paid_amount').replaceAll(
                                  '{value}',
                                  bezahlt
                                      .toStringAsFixed(2)
                                      .replaceAll('.', ','),
                                ),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                tr('total_amount').replaceAll(
                                  '{value}',
                                  gesamt
                                      .toStringAsFixed(2)
                                      .replaceAll('.', ','),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMitgliederSubView() {
    final members = _currentTeamMembers();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentTeamSubView = 'uebersicht'),
        ),
        title: const Text(
          'Mitglieder / Kaderliste',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Alle Spieler, Trainer und Betreuer des aktuell ausgewählten Teams.',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 14),
          if (members.isEmpty)
            const Card(
              color: kCardColor,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Für dieses Team sind noch keine Mitglieder hinterlegt.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...members.map((member) {
              final String rolle = member['rolle']?.toString() ?? '-';
              final bool isPlayer = rolle == 'Spieler';
              final String nummer = isPlayer
                  ? '#${member['rueckennummer']?.toString() ?? '-'}'
                  : '';

              return Card(
                color: kCardColor,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: kPrimaryColor.withValues(alpha: 0.2),
                    child: Text(
                      (member['name']?.toString() ?? '?')
                          .substring(0, 1)
                          .toUpperCase(),
                    ),
                  ),
                  title: Text(
                    member['name']?.toString() ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    isPlayer ? '$rolle • $nummer' : rolle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _showTeamMemberProfileDialog(member),
                  trailing: _isCoachOrAdmin
                      ? TextButton.icon(
                          onPressed: () => _showEditTeamMemberDialog(member),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Bearbeiten'),
                        )
                      : null,
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _showTeamMemberProfileDialog(Map<String, dynamic> member) async {
    final isPlayer = _isPlayerProfile(member);
    final canViewScorecard = isPlayer && _canEditScorecard;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: Text(
          member['name']?.toString() ?? 'Mitgliedsprofil',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: SizedBox(
          width: adaptiveDialogWidth(context, desktopWidth: 620),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildProfileInfoChip(
                      'Rolle',
                      member['rolle']?.toString() ?? '-',
                    ),
                    _buildProfileInfoChip(
                      'Rueckennummer',
                      member['rueckennummer']?.toString() ?? '-',
                    ),
                    _buildProfileInfoChip(
                      'Hauptposition',
                      member['hauptposition']?.toString() ?? '-',
                    ),
                    _buildProfileInfoChip(
                      'Starker Fuss',
                      member['starkerFuss']?.toString() ?? '-',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Notfall-Telefon',
                  member['notfallTelefon']?.toString() ?? '-',
                  accent: Colors.amber,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  'Medizinische Hinweise',
                  member['medizinischeHinweise']?.toString() ?? '-',
                ),
                if (canViewScorecard) ...[
                  const SizedBox(height: 14),
                  _buildScorecardSection(
                    member,
                    canEditScorecard: _canEditScorecard,
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('close')),
          ),
        ],
      ),
    );
  }

  // Dialog um einem Spieler eine vordefinierte Strafe aus dem Katalog zuzuweisen
  void _showStrafeVerhaengenDialog({
    String? initialSpieler,
    Map<String, dynamic>? initialRegel,
  }) {
    if (_strafenKatalog.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('fine_catalog_empty'))));
      return;
    }

    final spielerNamen =
        _spielerStatistiken
            .map((e) => e['name']?.toString() ?? '')
            .where((name) => name.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    if (spielerNamen.isEmpty) {
      spielerNamen.add(_currentUserName);
    }

    String gewaehlterSpieler = spielerNamen.contains(initialSpieler)
        ? initialSpieler!
        : spielerNamen.first;
    bool istBereitsBezahlt = false;
    Map<String, dynamic> gewaehlteRegel = _strafenKatalog.contains(initialRegel)
        ? initialRegel!
        : _strafenKatalog.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: kCardColor,
          title: Row(
            children: [
              const Icon(Icons.add_moderator, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(tr('assign_fine')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('step_1_player'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: kDarkBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: gewaehlterSpieler,
                    isExpanded: true,
                    dropdownColor: kCardColor,
                    items: spielerNamen
                        .map(
                          (name) => DropdownMenuItem(
                            value: name,
                            child: Text(
                              name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDlgState(() => gewaehlterSpieler = v!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tr('step_2_offense'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: kDarkBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: gewaehlteRegel,
                    isExpanded: true,
                    dropdownColor: kCardColor,
                    // Zeigt alle Regeln an, die du im Strafenkatalog-Tab live erstellt oder geändert hast
                    items: _strafenKatalog.map((regel) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: regel,
                        child: Text(
                          '${regel['regel']} (${((regel['strafe'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2).replaceAll('.', ',')} €)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setDlgState(() => gewaehlteRegel = v!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tr('step_3_payment'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text(tr('open')),
                      selected: !istBereitsBezahlt,
                      onSelected: (_) =>
                          setDlgState(() => istBereitsBezahlt = false),
                      selectedColor: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: Text(tr('already_paid')),
                      selected: istBereitsBezahlt,
                      onSelected: (_) =>
                          setDlgState(() => istBereitsBezahlt = true),
                      selectedColor: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                tr('cancel'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () {
                setState(() {
                  final regelText = gewaehlteRegel['regel'] as String? ?? '';
                  final regelBetrag =
                      (gewaehlteRegel['strafe'] as num?)?.toDouble() ?? 0.0;
                  if (istBereitsBezahlt) {
                    _kassenTransaktionen.insert(0, {
                      'datum': _formatTodayForList(),
                      'spieler': gewaehlterSpieler,
                      'grund': regelText,
                      'betrag': regelBetrag,
                      'typ': 'Einnahme',
                    });
                  } else {
                    _offeneStrafen.add({
                      'id': DateTime.now().millisecondsSinceEpoch,
                      'datum': _formatTodayForList(),
                      'spieler': gewaehlterSpieler,
                      'grund': regelText,
                      'betrag': regelBetrag,
                      'icon': Icons.person,
                      'offen': true,
                      'status': 'offen',
                      'bezahltVon': '',
                    });
                  }
                });
                Navigator.pop(context);

                // Kleine Bestätigung für den Trainer anzeigen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      tr(
                        'fine_recorded_for',
                      ).replaceAll('{name}', gewaehlterSpieler),
                    ),
                  ),
                );
              },
              child: Text(tr('book_fine')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRegelnSubView() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentTeamSubView = 'uebersicht'),
        ),
        title: Text(
          tr('fine_catalog'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _strafenKatalog.length,
        itemBuilder: (context, index) {
          final strafe = _strafenKatalog[index];
          return Card(
            color: kCardColor,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: kBorderColor),
            ),
            child: ListTile(
              leading: Icon(
                strafe['icon'] as IconData,
                color: Colors.redAccent,
                size: 30,
              ),
              title: Text(
                strafe['regel'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                strafe['beschreibung'] as String? ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: kDarkBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${((strafe['strafe'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2).replaceAll('.', ',')} €',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isVereinsAdmin)
                    IconButton(
                      tooltip: tr('delete_rule'),
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          _strafenKatalog.removeAt(index);
                        });
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _isVereinsAdmin
          ? FloatingActionButton(
              backgroundColor: kPrimaryColor,
              onPressed: _showKatalogRegelHinzufuegenDialog,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showKatalogRegelHinzufuegenDialog() {
    if (!_isVereinsAdmin) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('catalog_admin_only'))));
      return;
    }

    final regelController = TextEditingController();
    final strafeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: Text(tr('add_new_rule')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: regelController,
              decoration: InputDecoration(labelText: tr('rule_description')),
            ),
            TextField(
              controller: strafeController,
              decoration: InputDecoration(labelText: tr('fine_amount_label')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () {
              if (regelController.text.trim().isEmpty ||
                  strafeController.text.trim().isEmpty) {
                return;
              }
              final double strafe =
                  double.tryParse(
                    strafeController.text.trim().replaceAll(',', '.'),
                  ) ??
                  0.0;
              setState(() {
                _strafenKatalog.insert(0, {
                  'regel': regelController.text.trim(),
                  'strafe': strafe,
                  'icon': Icons.rule,
                });
              });
              Navigator.pop(context);
            },
            child: Text(tr('add')),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStatistikSubView() {
    final List<Map<String, dynamic>> sortierteStats = List.from(
      _spielerStatistiken,
    );
    int scoreValue(Map<String, dynamic> row) {
      final tore = (row['tore'] as num?)?.toInt() ?? 0;
      final vorlagen = (row['vorlagen'] as num?)?.toInt() ?? 0;
      return tore + vorlagen;
    }

    sortierteStats.sort((a, b) => scoreValue(b).compareTo(scoreValue(a)));
    final bool hasStats = sortierteStats.isNotEmpty;

    final Map<String, dynamic> topScorer = hasStats
        ? sortierteStats.first
        : {'name': '-', 'tore': 0};
    final Map<String, dynamic> bestVorlagen = hasStats
        ? sortierteStats.reduce(
            (value, element) =>
                ((element['vorlagen'] as num?)?.toInt() ?? 0) >
                    ((value['vorlagen'] as num?)?.toInt() ?? 0)
                ? element
                : value,
          )
        : {'name': '-', 'vorlagen': 0};
    final int averageParticipation = hasStats
        ? (_spielerStatistiken.fold<int>(
                    0,
                    (sum, item) =>
                        sum +
                        ((item['trainingsbeteiligung'] as num?)?.toInt() ?? 0),
                  ) /
                  _spielerStatistiken.length)
              .round()
        : 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentTeamSubView = 'uebersicht'),
        ),
        title: Text(
          tr('squad_statistics'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Module & Auswertungen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: kCardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment, color: Colors.orangeAccent),
              ),
              title: Text(
                tr('cards'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                tr('cards_desc'),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
              onTap: () => setState(() => _currentTeamSubView = 'karten'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: kCardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.insights, color: Colors.greenAccent),
              ),
              title: const Text(
                'Beteiligungs-Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: const Text(
                'Zeitraum- und Typfilter wie in SpielerPlus öffnen.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
              onTap: () =>
                  setState(() => _currentTeamSubView = 'beteiligungs_analyse'),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildTeamOverviewStatCard(
                width: 280,
                icon: Icons.star,
                title: tr('top_scorer'),
                value: '${topScorer['name']} (${topScorer['tore']} T)',
                color: Colors.tealAccent,
              ),
              _buildTeamOverviewStatCard(
                width: 280,
                icon: Icons.assessment,
                title: tr('best_assists'),
                value:
                    '${bestVorlagen['name']} (${bestVorlagen['vorlagen']} V)',
                color: Colors.indigoAccent,
              ),
              _buildTeamOverviewStatCard(
                width: 280,
                icon: Icons.calendar_today,
                title: tr('avg_participation_short'),
                value: '$averageParticipation %',
                color: Colors.greenAccent,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            tr('individual_stats'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kDarkBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 30,
                  child: Text(
                    '#',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    tr('player'),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    tr('goals_short'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    tr('assists_short'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    tr('participation_short'),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...sortierteStats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            final bool isTop3 = index < 3;
            final participation =
                (stat['trainingsbeteiligung'] as num?)?.toInt() ?? 0;

            return Container(
              decoration: BoxDecoration(
                color: isTop3
                    ? kPrimaryColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: kBorderColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${index + 1}.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isTop3 ? kPrimaryColor : Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      stat['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      ((stat['tore'] as num?)?.toInt() ?? 0).toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      ((stat['vorlagen'] as num?)?.toInt() ?? 0).toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '$participation%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: participation >= 90
                            ? Colors.greenAccent
                            : participation >= 75
                            ? Colors.amber
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Card(
            color: kCardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.white10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('analysis'),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('top_scorer_analysis')
                        .replaceAll('{name}', topScorer['name'].toString())
                        .replaceAll('{goals}', topScorer['tore'].toString()),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('best_assists_analysis')
                        .replaceAll('{name}', bestVorlagen['name'].toString())
                        .replaceAll(
                          '{assists}',
                          bestVorlagen['vorlagen'].toString(),
                        ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr(
                      'avg_participation_analysis',
                    ).replaceAll('{value}', averageParticipation.toString()),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SEITE 3: TERMINE (NEUE EIGENE SEITE FÜR ALLE TERMINE)
  // ─────────────────────────────────────────────────────────────────
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameCalendarDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Map<String, dynamic>> _eventsForCalendarDay(
    DateTime day,
    List<Map<String, dynamic>> termine,
  ) {
    final target = _dateOnly(day);
    return termine.where((termin) {
      final parsed = _parseTerminDateObj(termin);
      if (parsed == null) return false;
      return _isSameCalendarDay(_dateOnly(parsed), target);
    }).toList();
  }

  Color _markerColorForTerminType(String? type) {
    switch (type) {
      case 'Training':
        return Colors.greenAccent;
      case 'Spiel':
        return Colors.redAccent;
      case 'Sonstiges':
      default:
        return Colors.grey;
    }
  }

  Widget _buildCalendarLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildMonatsKalender(List<Map<String, dynamic>> termine) {
    return Card(
      color: kCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TableCalendar<Map<String, dynamic>>(
          firstDay: DateTime(DateTime.now().year - 1, 1, 1),
          lastDay: DateTime(DateTime.now().year + 2, 12, 31),
          focusedDay: _terminCalendarFocusedDay,
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: {CalendarFormat.month: tr('month')},
          selectedDayPredicate: (day) {
            final selected = _terminCalendarSelectedDay;
            return selected != null && _isSameCalendarDay(day, selected);
          },
          eventLoader: (day) => _eventsForCalendarDay(day, termine),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _terminCalendarSelectedDay = selectedDay;
              _terminCalendarFocusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _terminCalendarFocusedDay = focusedDay;
            });
          },
          calendarStyle: const CalendarStyle(
            outsideTextStyle: TextStyle(color: Colors.grey),
            defaultTextStyle: TextStyle(color: Colors.white),
            weekendTextStyle: TextStyle(color: Colors.white),
            todayDecoration: BoxDecoration(
              color: kSecondaryColor,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: kPrimaryColor,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(shape: BoxShape.circle),
            markerSize: 6,
          ),
          calendarBuilders: CalendarBuilders<Map<String, dynamic>>(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return const SizedBox.shrink();

              final colors = <Color>{};
              for (final event in events) {
                colors.add(_markerColorForTerminType(event['type'] as String?));
              }

              final dots = colors.take(3).toList();
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dots
                    .map(
                      (color) => Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.grey),
            weekendStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _buildInitialValuesForTerminType(String type) {
    final now = DateTime.now();
    final normalizedDate =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}';
    return {
      'event': type,
      'datum': normalizedDate,
      'zeit': '18:00',
      'treffzeit': '',
      'endzeit': '',
      'ort': '',
      'notiz': '',
      'untergrund': 'Rasen',
      'nominierteRollen': ['Trainer', 'Betreuer', 'Spieler'],
      'emailNotification': false,
      'pushNotification': true,
      'reasonRequired': type == 'Spiel' || type == 'Turnier',
      'isSerie': false,
      'wochenAnzahl': 4,
    };
  }

  void _selectTerminTypeForCreate(String type) {
    setState(() {
      _selectedTerminTypeForCreate = type;
      _currentTerminSubView = 'create_form';
    });
  }

  Map<String, dynamic> _mapImportedSpielToTermin(FussballDeMatchDto spiel) {
    final kick = spiel.kickoff ?? DateTime.now().add(const Duration(days: 2));
    final event = spiel.score.isNotEmpty
        ? '${spiel.homeTeam} vs. ${spiel.awayTeam} (${spiel.score})'
        : '${spiel.homeTeam} vs. ${spiel.awayTeam}';
    final kickoffTime = TimeOfDay(hour: kick.hour, minute: kick.minute);
    final matchId = spiel.matchId.trim();
    return {
      'matchId': matchId,
      'tag': _computeWeekdayLabel(kick),
      'datum': _formatDatumForStorage(kick),
      'zeit': _formatTimeOfDay(kickoffTime),
      'treffzeit': _formatTimeOfDay(
        TimeOfDay(
          hour: kickoffTime.hour > 0 ? kickoffTime.hour - 1 : 0,
          minute: kickoffTime.minute,
        ),
      ),
      'endzeit': _formatTimeOfDay(
        TimeOfDay(
          hour: kickoffTime.hour < 23 ? kickoffTime.hour + 2 : 23,
          minute: kickoffTime.minute,
        ),
      ),
      'event': event,
      'type': 'Spiel',
      'status': spiel.score.isNotEmpty ? 'Abgeschlossen' : 'Offen',
      'updatedAt': spiel.score.isNotEmpty ? 'Live-Ergebnis' : 'Importiert',
      'reasonRequired': true,
      'abmeldeGrund': '',
      'treffpunkt':
          'Treffzeit ${_formatTimeOfDay(TimeOfDay(hour: kickoffTime.hour > 0 ? kickoffTime.hour - 1 : 0, minute: kickoffTime.minute))}',
      'ort': spiel.venue,
      'untergrund': 'Rasen',
      'nominierteRollen': ['Trainer', 'Betreuer', 'Spieler'],
      'emailNotification': true,
      'pushNotification': true,
      'kleidung': 'Trikotsatz Heim',
      'notiz': [
        'Automatisch ueber DFBnet importiert.',
        if (spiel.competition.trim().isNotEmpty)
          'Wettbewerb: ${spiel.competition}',
        if (spiel.referee.trim().isNotEmpty) 'Schiedsrichter: ${spiel.referee}',
        if (spiel.matchUrl.trim().isNotEmpty) 'Link: ${spiel.matchUrl}',
      ].join(' • '),
      'teilnehmer': <Map<String, String>>[],
      'dateObj': DateTime(
        kick.year,
        kick.month,
        kick.day,
        kick.hour,
        kick.minute,
      ),
      'score': spiel.score,
      'competition': spiel.competition,
      'referee': spiel.referee,
      'matchUrl': spiel.matchUrl,
    };
  }

  String _importTerminMatchKey(Map<String, dynamic> termin) {
    final dateObj =
        termin['dateObj'] as DateTime? ?? _parseTerminDateObj(termin);
    final matchId = (termin['matchId'] as String?)?.trim() ?? '';
    if (matchId.isNotEmpty) {
      return 'id:$matchId';
    }

    final event = termin['event']?.toString() ?? '';
    final normalizedEvent = event
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9äöüß]+', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final dateKey = dateObj == null
        ? 'no-date'
        : '${dateObj.year.toString().padLeft(4, '0')}-${dateObj.month.toString().padLeft(2, '0')}-${dateObj.day.toString().padLeft(2, '0')}';
    return '$dateKey|$normalizedEvent';
  }

  void _applyImportedSpielplan(List<FussballDeMatchDto> imported) {
    final existingIndexByKey = <String, int>{};
    for (int i = 0; i < _allTermine.length; i++) {
      existingIndexByKey[_importTerminMatchKey(_allTermine[i])] = i;
    }

    for (final spiel in imported) {
      final mapped = _mapImportedSpielToTermin(spiel);
      final key = _importTerminMatchKey(mapped);
      final existingIndex = existingIndexByKey[key];

      if (existingIndex == null) {
        _allTermine.insert(0, mapped);
        existingIndexByKey[key] = 0;
        continue;
      }

      final target = _allTermine[existingIndex];
      target['matchId'] = mapped['matchId'];
      target['datum'] = mapped['datum'];
      target['tag'] = mapped['tag'];
      target['zeit'] = mapped['zeit'];
      target['treffzeit'] = mapped['treffzeit'];
      target['endzeit'] = mapped['endzeit'];
      target['ort'] = mapped['ort'];
      target['competition'] = mapped['competition'];
      target['referee'] = mapped['referee'];
      target['matchUrl'] = mapped['matchUrl'];

      if (spiel.score.trim().isNotEmpty) {
        target['score'] = spiel.score.trim();
        target['status'] = 'Abgeschlossen';
        target['updatedAt'] = 'Live-Ergebnis';
      } else if ((target['updatedAt']?.toString() ?? '').trim().isEmpty) {
        target['updatedAt'] = 'Importiert';
      }

      final mappedNote = mapped['notiz']?.toString().trim() ?? '';
      if (mappedNote.isNotEmpty &&
          (target['notiz']?.toString().trim().isEmpty ?? true)) {
        target['notiz'] = mappedNote;
      }
    }
  }

  Future<void> _importSpielplanVonFussballDe() async {
    if (_isImportingSpielplan) return;

    setState(() {
      _isImportingSpielplan = true;
    });

    try {
      final imported = await _fussballDeImportRepository.fetchTeamSchedule(
        teamId: _selectedFussballDeTeamId,
      );
      if (!mounted) return;

      setState(() {
        _applyImportedSpielplan(imported);
        _currentTerminSubView = 'list';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('fussball_import_done'))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('fussball_import_failed'))));
    } finally {
      if (mounted) {
        setState(() {
          _isImportingSpielplan = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _buildPreparationPhases({
    required DateTime start,
    required DateTime end,
    required String fokus,
    required String rawPhasenInput,
  }) {
    final safeEnd = end.isBefore(start)
        ? start
        : end.isAfter(
            start.add(const Duration(days: (kMaxPreparationWeeks * 7) - 1)),
          )
        ? start.add(const Duration(days: (kMaxPreparationWeeks * 7) - 1))
        : end;
    final totalWeeks = (((safeEnd.difference(start).inDays) / 7).floor() + 1)
        .clamp(1, kMaxPreparationWeeks);
    final userLines = rawPhasenInput
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final phases = <Map<String, dynamic>>[];
    for (int index = 0; index < totalWeeks; index++) {
      final week = index + 1;
      final schwerpunkt = userLines.length > index
          ? userLines[index]
          : '$fokus (Woche $week)';
      phases.add({'woche': week, 'schwerpunkt': schwerpunkt});
    }
    return phases;
  }

  String _formatTimeOfDay(TimeOfDay value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _buildVorbereitungTermin({
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String titel,
    required String fokus,
  }) {
    final start = _formatTimeOfDay(startTime);
    final end = _formatTimeOfDay(endTime);
    final tref = TimeOfDay(
      hour: startTime.hour,
      minute: (startTime.minute - 15) < 0 ? 0 : startTime.minute - 15,
    );
    final treff = _formatTimeOfDay(tref);
    final dateObj = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    return {
      'tag': _computeWeekdayLabel(dateObj),
      'datum': _formatDatumForStorage(dateObj),
      'zeit': start,
      'treffzeit': treff,
      'endzeit': end,
      'event': 'Vorbereitungstraining - $titel',
      'type': 'Training',
      'status': 'Offen',
      'updatedAt': 'Vorbereitungsgenerator',
      'reasonRequired': false,
      'abmeldeGrund': '',
      'treffpunkt': 'Treffzeit $treff',
      'ort': 'Vereinsgelaende',
      'untergrund': 'Rasen',
      'nominierteRollen': ['Trainer', 'Betreuer', 'Spieler'],
      'emailNotification': true,
      'pushNotification': true,
      'kleidung': 'Trainingsset',
      'notiz': 'Schwerpunkt: $fokus',
      'themen': '',
      'teilnehmer': <Map<String, String>>[],
      'isVorbereitung': true,
      'dateObj': dateObj,
    };
  }

  int _countVorbereitungTermineForWeek({
    required DateTime planStart,
    required DateTime planEnd,
    required int week,
  }) {
    final safeWeek = week.clamp(1, kMaxPreparationWeeks);
    final start = DateTime(
      planStart.year,
      planStart.month,
      planStart.day,
    ).add(Duration(days: (safeWeek - 1) * 7));
    final end = start.add(const Duration(days: 6));
    final cappedEnd = end.isAfter(planEnd) ? planEnd : end;

    return _allTermine.where((termin) {
      if (termin['isVorbereitung'] != true) return false;
      final dateObj =
          (termin['dateObj'] as DateTime?) ?? _parseTerminDateObj(termin);
      if (dateObj == null) return false;
      final day = DateTime(dateObj.year, dateObj.month, dateObj.day);
      return !day.isBefore(start) && !day.isAfter(cappedEnd);
    }).length;
  }

  Future<void> _openVorbereitungsDatei(Map<String, dynamic> fileEntry) async {
    final path = fileEntry['path']?.toString() ?? '';
    if (path.trim().isEmpty) return;

    final uri = Uri.file(path);
    final canOpen = await canLaunchUrl(uri);
    if (!canOpen) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datei konnte nicht geoeffnet werden.')),
      );
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _pickVorbereitungsDatei() async {
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'xlsx', 'xls'],
      );

      if (picked == null) return;
      final path = picked.path;
      if (path == null || path.trim().isEmpty) return;

      if (!mounted) return;

      setState(() {
        _vorbereitungsDateien.add({
          'name': picked.name,
          'path': path,
          'uploadedAt': _formatTodayForList(),
          'uploadedBy': _currentUserName,
        });
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datei "${picked.name}" wurde angeheftet.')),
      );
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dateiauswahl ist noch nicht nativerseitig geladen. Bitte App komplett neu starten (kein Hot-Reload).',
          ),
        ),
      );
    } on PlatformException catch (error) {
      if (!mounted) return;
      final details = error.message?.trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            details == null || details.isEmpty
                ? 'Dateiauswahl fehlgeschlagen. Bitte erneut versuchen.'
                : 'Dateiauswahl fehlgeschlagen: $details',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unerwarteter Fehler bei der Dateiauswahl.'),
        ),
      );
    }
  }

  String _filePickerPlatformHint() {
    if (kIsWeb) {
      return 'Web: Dateiauswahl laeuft im Browser. Bei Problemen Seite neu laden.';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android: Nach Plugin-Updates immer App komplett stoppen und mit flutter clean; flutter pub get; flutter run neu starten.';
      case TargetPlatform.iOS:
        return 'iOS: Nach Plugin-Updates App komplett neu bauen (kein Hot Reload). Falls noetig zusaetzlich pod install im ios-Ordner ausfuehren.';
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'Desktop: Nach Plugin-Updates App vollstaendig neu starten.';
      case TargetPlatform.fuchsia:
        return 'Plugin-Hinweis: Bei nativen Channel-Fehlern App komplett neu starten.';
    }
  }

  Widget _buildFilePickerHintCard() {
    return Card(
      color: kCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.orangeAccent.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Colors.orangeAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _filePickerPlatformHint(),
                style: const TextStyle(color: Colors.white70, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStatsVonDatum() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _statsVonDatum,
      firstDate: DateTime(2000),
      lastDate: _statsBisDatum.isAfter(_statsVonDatum)
          ? _statsBisDatum
          : DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      _statsVonDatum = _dateOnly(picked);
      if (_statsVonDatum.isAfter(_statsBisDatum)) {
        _statsBisDatum = _statsVonDatum;
      }
    });
  }

  Future<void> _pickStatsBisDatum() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _statsBisDatum,
      firstDate: _statsVonDatum,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      _statsBisDatum = _dateOnly(picked);
      if (_statsBisDatum.isBefore(_statsVonDatum)) {
        _statsVonDatum = _statsBisDatum;
      }
    });
  }

  String _formatStatsDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  List<Map<String, dynamic>> _filteredBeteiligungsTermine() {
    final start = _dateOnly(_statsVonDatum);
    final end = _dateOnly(_statsBisDatum).add(const Duration(days: 1));
    final termine = _allTermine.where((termin) {
      final dateObj = _parseTerminDateObj(termin);
      if (dateObj == null) return false;
      if (dateObj.isBefore(start) || !dateObj.isBefore(end)) return false;
      final type = _statsTerminType(termin);
      return _aktivierteStatsTypen.contains(type);
    }).toList();

    termine.sort((a, b) {
      final aDate =
          _parseTerminDateObj(a) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate =
          _parseTerminDateObj(b) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);
    });
    return termine;
  }

  String _statsTerminType(Map<String, dynamic> termin) {
    final raw = termin['type']?.toString().trim() ?? '';
    return raw.isNotEmpty
        ? raw
        : _inferTerminType(termin['event']?.toString() ?? '');
  }

  Map<String, dynamic> _calculateBeteiligungsKennzahlen(
    List<Map<String, dynamic>> termine,
  ) {
    final spieler = _currentTeamMembers()
        .where((member) => (member['rolle']?.toString() ?? '') == 'Spieler')
        .toList();
    final List<Map<String, dynamic>> spielerStats = spieler.map((member) {
      final name = member['name']?.toString() ?? '-';
      int anwesend = 0;
      final int gesamt = termine.length;

      for (final termin in termine) {
        final teilnehmer =
            (termin['teilnehmer'] as List?)?.cast<Map>() ?? <Map>[];
        Map<String, dynamic>? eintrag;
        for (final item in teilnehmer) {
          final typed = Map<String, dynamic>.from(item);
          if ((typed['name']?.toString() ?? '') == name) {
            eintrag = typed;
            break;
          }
        }
        if (eintrag != null && eintrag['status']?.toString() == 'Zusage') {
          anwesend++;
        }
      }

      final double prozent = gesamt == 0 ? 0.0 : (anwesend / gesamt) * 100.0;
      return {
        'name': name,
        'anwesend': anwesend,
        'gesamt': gesamt,
        'prozent': prozent,
      };
    }).toList();

    spielerStats.sort((a, b) {
      final compare = ((b['prozent'] as num?)?.toDouble() ?? 0.0).compareTo(
        (a['prozent'] as num?)?.toDouble() ?? 0.0,
      );
      if (compare != 0) return compare;
      return (a['name'] as String).compareTo(b['name'] as String);
    });

    final double durchschnitt = spielerStats.isEmpty
        ? 0.0
        : spielerStats.fold<double>(
                0.0,
                (sum, item) =>
                    sum + ((item['prozent'] as num?)?.toDouble() ?? 0.0),
              ) /
              spielerStats.length;

    return {'spielerStats': spielerStats, 'durchschnitt': durchschnitt};
  }

  Future<void> _showTerminTeilnehmerDialog(Map<String, dynamic> termin) async {
    final teilnehmer = ((termin['teilnehmer'] as List?) ?? <dynamic>[])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final zusagen = teilnehmer
        .where((entry) => (entry['status']?.toString() ?? '') == 'Zusage')
        .toList();
    final absagen = teilnehmer
        .where((entry) => (entry['status']?.toString() ?? '') == 'Absage')
        .toList();
    final unsicher = teilnehmer
        .where((entry) => (entry['status']?.toString() ?? '') == 'Unsicher')
        .toList();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: Text(termin['event']?.toString() ?? 'Termin'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_statsTerminType(termin)} • ${termin['datum'] ?? '-'} ${termin['zeit'] ?? ''}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 14),
                Text(
                  'Zugesagt (${zusagen.length})',
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  zusagen.isEmpty
                      ? '-'
                      : zusagen
                            .map((entry) => entry['name']?.toString() ?? '-')
                            .join(', '),
                ),
                const SizedBox(height: 10),
                Text(
                  'Abgesagt (${absagen.length})',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  absagen.isEmpty
                      ? '-'
                      : absagen
                            .map((entry) {
                              final grund = entry['grund']?.toString() ?? '';
                              final name = entry['name']?.toString() ?? '-';
                              return grund.trim().isEmpty
                                  ? name
                                  : '$name ($grund)';
                            })
                            .join(', '),
                ),
                const SizedBox(height: 10),
                Text(
                  'Unsicher (${unsicher.length})',
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  unsicher.isEmpty
                      ? '-'
                      : unsicher
                            .map((entry) {
                              final grund = entry['grund']?.toString() ?? '';
                              final name = entry['name']?.toString() ?? '-';
                              return grund.trim().isEmpty
                                  ? name
                                  : '$name ($grund)';
                            })
                            .join(', '),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDateButton({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: kDarkBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                _formatStatsDate(value),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBeteiligungsChip(String type) {
    final bool selected = _aktivierteStatsTypen.contains(type);
    return FilterChip(
      selected: selected,
      label: Text(type, maxLines: 1, overflow: TextOverflow.ellipsis),
      onSelected: (value) {
        setState(() {
          if (value) {
            _aktivierteStatsTypen.add(type);
          } else if (_aktivierteStatsTypen.length > 1) {
            _aktivierteStatsTypen.remove(type);
          }
        });
      },
      selectedColor: Colors.tealAccent.withValues(alpha: 0.18),
      backgroundColor: kDarkBackground,
      checkmarkColor: Colors.tealAccent,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.white70,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: selected ? Colors.tealAccent : Colors.white12),
    );
  }

  Widget _buildTeamBeteiligungsAnalyseView() {
    final termine = _filteredBeteiligungsTermine();
    final kennzahlen = _calculateBeteiligungsKennzahlen(termine);
    final List<Map<String, dynamic>> spielerStats =
        (kennzahlen['spielerStats'] as List).cast<Map<String, dynamic>>();
    final double durchschnitt = (kennzahlen['durchschnitt'] as double?) ?? 0.0;
    final List<Map<String, dynamic>> spieler = _currentTeamMembers()
        .where((member) => (member['rolle']?.toString() ?? '') == 'Spieler')
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentTeamSubView = 'statistik'),
        ),
        title: const Text(
          'Beteiligungs-Analyse',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: kCardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Zeitraum',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatsDateButton(
                          label: 'Von',
                          value: _statsVonDatum,
                          onTap: _pickStatsVonDatum,
                        ),
                        const SizedBox(width: 12),
                        _buildStatsDateButton(
                          label: 'Bis',
                          value: _statsBisDatum,
                          onTap: _pickStatsBisDatum,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Filter',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildBeteiligungsChip('Spiel'),
                        _buildBeteiligungsChip('Training'),
                        _buildBeteiligungsChip('Event'),
                        _buildBeteiligungsChip('Turnier'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildTeamOverviewStatCard(
                  width: 280,
                  icon: Icons.groups,
                  title: 'Beruecksichtigte Spieler',
                  value: '${spielerStats.length}',
                  color: Colors.tealAccent,
                ),
                _buildTeamOverviewStatCard(
                  width: 280,
                  icon: Icons.event_note,
                  title: 'Beruecksichtigte Termine',
                  value: '${termine.length}',
                  color: Colors.lightBlueAccent,
                ),
                _buildTeamOverviewStatCard(
                  width: 280,
                  icon: Icons.pie_chart,
                  title: 'Durchschnittliche Anwesenheit',
                  value: '${durchschnitt.toStringAsFixed(1)} %',
                  color: Colors.greenAccent,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Card(
              color: kCardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gesamtwertung',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll(
                          kDarkBackground,
                        ),
                        dataRowMinHeight: 44,
                        dataRowMaxHeight: 60,
                        columns: const [
                          DataColumn(label: Text('Spieler')),
                          DataColumn(label: Text('Anwesend')),
                          DataColumn(label: Text('Termine')),
                          DataColumn(label: Text('%')),
                        ],
                        rows: spielerStats.map((entry) {
                          final prozent = (entry['prozent'] as double?) ?? 0.0;
                          final color = prozent >= 90
                              ? Colors.greenAccent
                              : prozent >= 75
                              ? Colors.amberAccent
                              : Colors.orangeAccent;
                          return DataRow(
                            cells: [
                              DataCell(Text(entry['name']?.toString() ?? '-')),
                              DataCell(Text('${entry['anwesend']}')),
                              DataCell(Text('${entry['gesamt']}')),
                              DataCell(
                                Text(
                                  '${prozent.toStringAsFixed(1)} %',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Card(
              color: kCardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Termine im Detail',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (termine.isEmpty)
                      const Text(
                        'Für die gewählten Filter wurden keine Termine gefunden.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStatePropertyAll(
                            kDarkBackground,
                          ),
                          dataRowMinHeight: 48,
                          dataRowMaxHeight: 72,
                          columns: [
                            const DataColumn(label: Text('Termin')),
                            ...spieler.map(
                              (member) => DataColumn(
                                label: SizedBox(
                                  width: 90,
                                  child: Text(
                                    member['name']?.toString() ?? '-',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          rows: termine.map((termin) {
                            final type = _statsTerminType(termin);
                            final dateObj = _parseTerminDateObj(termin);
                            final datumText = dateObj == null
                                ? (termin['datum']?.toString() ?? '-')
                                : _formatStatsDate(dateObj);
                            final eventText =
                                termin['event']?.toString() ?? '-';
                            final teilnehmer =
                                ((termin['teilnehmer'] as List?) ?? <dynamic>[])
                                    .whereType<Map>()
                                    .map((e) => Map<String, dynamic>.from(e))
                                    .toList();

                            return DataRow(
                              onSelectChanged: (_) =>
                                  _showTerminTeilnehmerDialog(termin),
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 220,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$type $datumText',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          eventText,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ...spieler.map((member) {
                                  final name = member['name']?.toString() ?? '';
                                  Map<String, dynamic>? eintrag;
                                  for (final item in teilnehmer) {
                                    if ((item['name']?.toString() ?? '') ==
                                        name) {
                                      eintrag = item;
                                      break;
                                    }
                                  }
                                  final status =
                                      eintrag?['status']?.toString() ?? '-';
                                  final bool present = status == 'Zusage';
                                  return DataCell(
                                    Center(
                                      child: Icon(
                                        present
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: present
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showVorbereitungErstellenDialog() async {
    if (!_canManageVorbereitung) return;

    DateTime startDate = DateTime(DateTime.now().year, 7, 1);
    DateTime endDate = DateTime(DateTime.now().year, 8, 15);
    TimeOfDay startTime = const TimeOfDay(hour: 18, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 19, minute: 30);
    final Set<int> weekdays = <int>{2, 4, 6};

    final titleController = TextEditingController(
      text: 'Sommervorbereitung ${DateTime.now().year}',
    );
    final fokusController = TextEditingController(
      text: 'Grundlagenausdauer & Taktik',
    );
    final phasenController = TextEditingController(
      text:
          'Ausdauer & Core-Stabilitaet\nSpielerische Ausdauer & Kleinfeldspiele\nTaktik & Teambuilding (Trainingslager)',
    );

    const weekdayLabels = <int, String>{
      1: 'Montag',
      2: 'Dienstag',
      3: 'Mittwoch',
      4: 'Donnerstag',
      5: 'Freitag',
      6: 'Samstag',
      7: 'Sonntag',
    };

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: kCardColor,
              title: const Text('Vorbereitung generieren'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Titel der Vorbereitung',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: fokusController,
                        decoration: const InputDecoration(
                          labelText: 'Gesamtfokus',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: startDate,
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 365),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365 * 3),
                                  ),
                                );
                                if (picked == null) return;
                                setDialogState(() {
                                  startDate = picked;
                                  if (endDate.isBefore(startDate)) {
                                    endDate = startDate.add(
                                      const Duration(days: 35),
                                    );
                                  }
                                });
                              },
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                'Start: ${_formatDatumForStorage(startDate)}',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: endDate,
                                  firstDate: startDate,
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365 * 3),
                                  ),
                                );
                                if (picked == null) return;
                                setDialogState(() {
                                  endDate = picked;
                                });
                              },
                              icon: const Icon(Icons.event),
                              label: Text(
                                'Ende: ${_formatDatumForStorage(endDate)}',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Trainingstage pro Woche',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ...weekdayLabels.entries.map((entry) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: weekdays.contains(entry.key),
                          title: Text(entry.value),
                          onChanged: (checked) {
                            setDialogState(() {
                              if (checked == true) {
                                weekdays.add(entry.key);
                              } else {
                                weekdays.remove(entry.key);
                              }
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: startTime,
                                );
                                if (picked == null) return;
                                setDialogState(() {
                                  startTime = picked;
                                });
                              },
                              icon: const Icon(Icons.schedule),
                              label: Text(
                                'Startzeit: ${_formatTimeOfDay(startTime)}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: endTime,
                                );
                                if (picked == null) return;
                                setDialogState(() {
                                  endTime = picked;
                                });
                              },
                              icon: const Icon(Icons.timer),
                              label: Text(
                                'Endzeit: ${_formatTimeOfDay(endTime)}',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phasenController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText:
                              'Wochen-Schwerpunkte (je Zeile eine Woche)',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(tr('cancel')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                  ),
                  onPressed: () {
                    final startMinutes = startTime.hour * 60 + startTime.minute;
                    final endMinutes = endTime.hour * 60 + endTime.minute;

                    if (titleController.text.trim().isEmpty ||
                        fokusController.text.trim().isEmpty ||
                        weekdays.isEmpty ||
                        endDate.isBefore(startDate) ||
                        endMinutes <= startMinutes) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Bitte Eingaben pruefen (Zeitraum, Tage und Uhrzeiten).',
                          ),
                        ),
                      );
                      return;
                    }

                    final phases = _buildPreparationPhases(
                      start: startDate,
                      end: endDate,
                      fokus: fokusController.text.trim(),
                      rawPhasenInput: phasenController.text,
                    );

                    final requestedEnd = DateTime(
                      endDate.year,
                      endDate.month,
                      endDate.day,
                    );
                    final boundedEnd =
                        requestedEnd.isAfter(
                          DateTime(
                            startDate.year,
                            startDate.month,
                            startDate.day,
                          ).add(
                            const Duration(
                              days: (kMaxPreparationWeeks * 7) - 1,
                            ),
                          ),
                        )
                        ? DateTime(
                            startDate.year,
                            startDate.month,
                            startDate.day,
                          ).add(
                            const Duration(
                              days: (kMaxPreparationWeeks * 7) - 1,
                            ),
                          )
                        : requestedEnd;

                    final generated = <Map<String, dynamic>>[];
                    final loopStart = DateTime(
                      startDate.year,
                      startDate.month,
                      startDate.day,
                    );
                    for (
                      int dayOffset = 0;
                      dayOffset < kMaxPreparationWeeks * 7;
                      dayOffset++
                    ) {
                      final d = loopStart.add(Duration(days: dayOffset));
                      if (d.isAfter(boundedEnd)) break;
                      if (!weekdays.contains(d.weekday)) continue;
                      generated.add(
                        _buildVorbereitungTermin(
                          date: d,
                          startTime: startTime,
                          endTime: endTime,
                          titel: titleController.text.trim(),
                          fokus: fokusController.text.trim(),
                        ),
                      );
                    }

                    setState(() {
                      // Fehlertolerantes Filtern: Vorbereitungstermine im Zeitraum entfernen
                      _allTermine.removeWhere((termin) {
                        if (termin['isVorbereitung'] != true) return false;
                        try {
                          final DateTime? d = termin['dateObj'] is DateTime
                              ? termin['dateObj'] as DateTime
                              : DateTime.tryParse(
                                  termin['dateObj']?.toString() ?? '',
                                );

                          if (d == null) {
                            return true; // Ungültige Termine entfernen
                          }
                          final day = DateTime(d.year, d.month, d.day);
                          return !day.isBefore(loopStart) &&
                              !day.isAfter(boundedEnd);
                        } catch (_) {
                          return true; // Fehlerhafte Termine entfernen
                        }
                      });

                      // Sichere Konvertierung der generierten Maps, um den Typenkonflikt zu lösen:
                      final List<Map<String, Object>> typedGenerated = generated
                          .map((e) => Map<String, Object>.from(e))
                          .toList();
                      _allTermine.addAll(typedGenerated);

                      // Sichere Sortierung ohne Endlosschleife
                      _allTermine.sort((a, b) {
                        try {
                          final da = a['dateObj'] is DateTime
                              ? a['dateObj'] as DateTime
                              : DateTime.tryParse(
                                  a['dateObj']?.toString() ?? '',
                                );
                          final db = b['dateObj'] is DateTime
                              ? b['dateObj'] as DateTime
                              : DateTime.tryParse(
                                  b['dateObj']?.toString() ?? '',
                                );

                          if (da == null && db == null) return 0;
                          if (da == null) return 1;
                          if (db == null) return -1;
                          return da.compareTo(db);
                        } catch (_) {
                          return 0; // Bei Fehler neutral sortieren
                        }
                      });

                      _selectedTeam['vorbereitungsPlan'] = {
                        'istAktiv': true,
                        'titel': titleController.text.trim(),
                        'startDatum': _formatDatumForStorage(loopStart),
                        'endDatum': _formatDatumForStorage(boundedEnd),
                        'fokus': fokusController.text.trim(),
                        'phasen': phases,
                      };
                      _currentTerminSubView = 'vorbereitung_overview';
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          boundedEnd.isBefore(requestedEnd)
                              ? 'Vorbereitung auf max. $kMaxPreparationWeeks Wochen begrenzt: ${generated.length} Termine erstellt.'
                              : 'Vorbereitung erstellt: ${generated.length} Trainingstermine hinzugefuegt.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Plan erstellen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildVorbereitungOverviewScreen() {
    final plan = _vorbereitungsPlan;
    final planActive = plan != null && plan['istAktiv'] == true;

    if (!planActive) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Saison-Vorbereitungsplan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lege eine intensive Vorbereitungsphase an und generiere automatisch alle Trainingstermine.',
            style: TextStyle(color: Colors.grey, height: 1.35),
          ),
          const SizedBox(height: 18),
          Card(
            color: kCardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white10),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Es ist derzeit keine aktive Vorbereitungsphase hinterlegt.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          if (_canManageVorbereitung) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: _showVorbereitungErstellenDialog,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Vorbereitung generieren'),
            ),
            const SizedBox(height: 10),
            _buildFilePickerHintCard(),
          ],
        ],
      );
    }

    final startDate =
        _parseDateOnly(plan['startDatum']?.toString() ?? '') ?? DateTime.now();
    final endDate =
        _parseDateOnly(plan['endDatum']?.toString() ?? '') ?? startDate;
    final today = DateTime.now();
    final totalDays = endDate.difference(startDate).inDays + 1;
    final elapsedDays = today.isBefore(startDate)
        ? 0
        : today.isAfter(endDate)
        ? totalDays
        : today.difference(startDate).inDays + 1;
    final progress = totalDays <= 0
        ? 0.0
        : (elapsedDays / totalDays).clamp(0.0, 1.0);

    final phases =
        ((plan['phasen'] as List?)?.cast<Map<String, dynamic>>() ??
                <Map<String, dynamic>>[])
            .take(kMaxPreparationWeeks)
            .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _currentTerminSubView = 'list'),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Saison-Vorbereitungsplan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          color: kCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: kPrimaryColor.withValues(alpha: 0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan['titel']?.toString() ?? 'Vorbereitung',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fokus: ${plan['fokus']?.toString() ?? '-'}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  'Zeitraum: ${plan['startDatum']} bis ${plan['endDatum']}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                  color: kPrimaryColor,
                  backgroundColor: Colors.white12,
                ),
                const SizedBox(height: 8),
                Text(
                  '$elapsedDays von $totalDays Tagen absolviert',
                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (_canManageVorbereitung)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                onPressed: _showVorbereitungErstellenDialog,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Vorbereitung generieren'),
              ),
              OutlinedButton.icon(
                onPressed: _pickVorbereitungsDatei,
                icon: const Icon(Icons.upload_file),
                label: const Text(
                  'Vorbereitungsplan als Datei hochladen (PDF/XLSX)',
                ),
              ),
            ],
          ),
        if (_canManageVorbereitung) ...[
          const SizedBox(height: 10),
          _buildFilePickerHintCard(),
        ],
        const SizedBox(height: 16),
        const Text(
          'Wochen-Fahrplan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...phases.map((phase) {
          final week = (phase['woche'] as num?)?.toInt() ?? 1;
          final schwerpunkt = phase['schwerpunkt']?.toString() ?? '-';
          final termine = _countVorbereitungTermineForWeek(
            planStart: DateTime(startDate.year, startDate.month, startDate.day),
            planEnd: DateTime(endDate.year, endDate.month, endDate.day),
            week: week,
          );

          return Card(
            color: kCardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Colors.white10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Woche $week',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schwerpunkt,
                    style: const TextStyle(color: Colors.white70, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$termine Termine in dieser Woche',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Card(
          color: kCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Colors.white10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datei-Import / Download',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (_vorbereitungsDateien.isEmpty)
                  const Text(
                    'Noch keine Datei angeheftet.',
                    style: TextStyle(color: Colors.white70),
                  )
                else
                  ..._vorbereitungsDateien.map((file) {
                    final name = file['name']?.toString() ?? 'Datei';
                    final uploadedAt = file['uploadedAt']?.toString() ?? '-';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(name),
                      subtitle: Text('Angeheftet am $uploadedAt'),
                      trailing: const Icon(Icons.download),
                      onTap: () => _openVorbereitungsDatei(file),
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTerminTypeCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminTypeSelectScreen() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _currentTerminSubView = 'list'),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                tr('termin_select_title'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          tr('termin_select_subtitle'),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 16),
        Text(
          tr('manual_create_section'),
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: [
            _buildTerminTypeCard(
              title: tr('type_training'),
              icon: Icons.analytics,
              color: Colors.greenAccent,
              onTap: () => _selectTerminTypeForCreate('Training'),
            ),
            _buildTerminTypeCard(
              title: tr('type_game'),
              icon: Icons.sports_soccer,
              color: Colors.redAccent,
              onTap: () => _selectTerminTypeForCreate('Spiel'),
            ),
            _buildTerminTypeCard(
              title: tr('type_tournament'),
              icon: Icons.emoji_events,
              color: Colors.amberAccent,
              onTap: () => _selectTerminTypeForCreate('Turnier'),
            ),
            _buildTerminTypeCard(
              title: tr('type_event'),
              icon: Icons.groups,
              color: Colors.blueAccent,
              onTap: () => _selectTerminTypeForCreate('Event'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Card(
          color: kCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: kPrimaryColor.withValues(alpha: 0.45)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'FUSSBALL.DE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr('fussball_import_title'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tr('fussball_import_info'),
                  style: const TextStyle(color: Colors.grey, height: 1.35),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isImportingSpielplan
                        ? null
                        : _importSpielplanVonFussballDe,
                    child: _isImportingSpielplan
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(tr('fussball_import_loading')),
                            ],
                          )
                        : Text(tr('fussball_import_button')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTerminFormScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: TerminFormDialog(
        isEdit: false,
        allowSeries: true,
        initialValues: _buildInitialValuesForTerminType(
          _selectedTerminTypeForCreate,
        ),
        fullscreenMode: true,
        onBack: () => setState(() => _currentTerminSubView = 'select_type'),
        pageTitle: tr('create_fullscreen_title'),
        onSave: (valueMap) {
          setState(() {
            _saveTerminFromValueMap(valueMap);
            _currentTerminSubView = 'list';
          });
          final bool isSerie = valueMap['isSerie'] == true;
          final int wochen = (valueMap['wochenAnzahl'] as num?)?.toInt() ?? 1;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isSerie
                    ? tr(
                        'series_created_count',
                      ).replaceAll('{count}', wochen.toString())
                    : tr('event_created'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllTermineBody() {
    if (_currentTerminSubView == 'vorbereitung_overview') {
      return _buildVorbereitungOverviewScreen();
    }
    if (_currentTerminSubView == 'select_type') {
      return _buildTerminTypeSelectScreen();
    }
    if (_currentTerminSubView == 'create_form') {
      return _buildTerminFormScreen();
    }

    final now = DateTime.now();
    final filtered = _allTermine.where((termin) {
      if (_terminFilterType == 'Alle') return true;
      return (termin['type'] as String?) == _terminFilterType;
    }).toList();

    final selectedDayTermine =
        _terminCalendarSelectedDay == null
              ? <Map<String, dynamic>>[]
              : _eventsForCalendarDay(_terminCalendarSelectedDay!, filtered)
          ..sort((a, b) {
            final da = _parseTerminDateObj(a);
            final db = _parseTerminDateObj(b);
            if (da == null && db == null) return 0;
            if (da == null) return 1;
            if (db == null) return -1;
            return da.compareTo(db);
          });

    final upcoming =
        filtered.where((termin) => _terminIsUpcoming(termin, now)).toList()
          ..sort((a, b) {
            final da = _parseTerminDateObj(a);
            final db = _parseTerminDateObj(b);
            if (da == null && db == null) return 0;
            if (da == null) return 1;
            if (db == null) return -1;
            return da.compareTo(db);
          });
    final history =
        filtered.where((termin) => !_terminIsUpcoming(termin, now)).toList()
          ..sort((a, b) {
            final da = _parseTerminDateObj(a);
            final db = _parseTerminDateObj(b);
            if (da == null && db == null) return 0;
            if (da == null) return 1;
            if (db == null) return -1;
            return db.compareTo(da);
          });

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          tr('overview_schedule'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tr('filter_schedule'),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        if (_isCoachOrAdmin) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _showKombiniertenTerminPlaner(context),
              icon: const Icon(Icons.event_available),
              label: Text(tr('create_termin')),
            ),
          ),
        ],
        if (_vorbereitungsPlan != null &&
            _vorbereitungsPlan?['istAktiv'] == true) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(
                () => _currentTerminSubView = 'vorbereitung_overview',
              ),
              icon: const Icon(Icons.fitness_center),
              label: const Text('Saison-Vorbereitungsplan oeffnen'),
            ),
          ),
        ] else if (_canManageVorbereitung) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showVorbereitungErstellenDialog,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Vorbereitung generieren'),
            ),
          ),
        ],
        const SizedBox(height: 18),
        _buildTerminFilterChips(),
        const SizedBox(height: 14),
        _buildMonatsKalender(filtered),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _buildCalendarLegendDot(Colors.greenAccent, tr('training')),
            _buildCalendarLegendDot(Colors.redAccent, tr('game')),
            _buildCalendarLegendDot(Colors.grey, tr('other')),
          ],
        ),
        if (_terminCalendarSelectedDay != null) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  tr('events_on_date').replaceAll(
                    '{date}',
                    '${_terminCalendarSelectedDay!.day.toString().padLeft(2, '0')}.${_terminCalendarSelectedDay!.month.toString().padLeft(2, '0')}.${_terminCalendarSelectedDay!.year}',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => _terminCalendarSelectedDay = null),
                child: Text(tr('clear_filter')),
              ),
            ],
          ),
          if (selectedDayTermine.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text(
                tr('no_events_selected_day'),
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else
            ...selectedDayTermine.map((termin) {
              final index = _allTermine.indexOf(termin);
              return _buildWeeklyTerminRow(index, termin);
            }),
        ],
        const SizedBox(height: 20),
        if (upcoming.isEmpty)
          Card(
            color: kCardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.white10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                tr('no_upcoming_in_category'),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
        else ...[
          ...upcoming.map((termin) {
            final index = _allTermine.indexOf(termin);
            return _buildWeeklyTerminRow(index, termin);
          }),
        ],
        if (history.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            tr('past_events'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...history.map((termin) {
            final index = _allTermine.indexOf(termin);
            return _buildWeeklyTerminRow(index, termin);
          }),
        ],
      ],
    );
  }

  Widget _buildTerminFilterChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _terminGroups.map((group) {
        final selected = _terminFilterType == group['type'];
        String label = group['label'] as String;
        switch (group['type']) {
          case 'Alle':
            label = tr('all');
            break;
          case 'Training':
            label = tr('training');
            break;
          case 'Spiel':
            label = tr('game');
            break;
          case 'Sonstiges':
            label = tr('other');
            break;
        }
        return ChoiceChip(
          label: Text(label),
          selected: selected,
          selectedColor: kPrimaryColor,
          backgroundColor: kCardColor,
          labelStyle: TextStyle(color: selected ? Colors.black : Colors.white),
          onSelected: (_) =>
              setState(() => _terminFilterType = group['type'] as String),
        );
      }).toList(),
    );
  }

  bool _terminIsUpcoming(Map<String, dynamic> termin, DateTime now) {
    final dateObj = _parseTerminDateObj(termin);
    if (dateObj == null) return false;
    return !dateObj.isBefore(now);
  }

  Widget _buildDashboardInfoBanner(
    String title,
    String message,
    IconData icon,
    Color accent,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasOpenAbstimmungen() {
    return _aktiveAbstimmungen.where((v) => v['voted'] == false).isNotEmpty;
  }

  int _getOpenAbstimmungenCount() {
    return _aktiveAbstimmungen.where((v) => v['voted'] == false).length;
  }

  double _currentUserDebt() {
    return _playerDebts[_currentUserName] ?? 0.0;
  }

  // Liefert die Indices der Termine, die in den nächsten 7 Tagen stattfinden
  List<int> _getTermineIndicesNextWeek() {
    final now = DateTime.now();
    final end = now.add(const Duration(days: 7));
    final List<int> indices = [];
    for (int i = 0; i < _allTermine.length; i++) {
      final t = _allTermine[i];
      DateTime? d;
      if (t['dateObj'] is DateTime) {
        d = t['dateObj'] as DateTime;
      } else {
        d = _parseTerminDateObj(t);
      }
      if (d != null) {
        if (!d.isBefore(now) && d.isBefore(end)) indices.add(i);
      }
    }
    return indices;
  }

  Widget _buildWeeklyTerminRow(int index, Map<String, dynamic> termin) {
    return TerminCard(
      index: index,
      termin: termin,
      isExpanded: _expandedTermine[index] ?? false,
      isCoachOrAdmin: _isCoachOrAdmin,
      onToggleExpand: () => _toggleExpandTermin(index),
      onShowTeilnehmer: () => _zeigeTeilnehmerListe(index),
      onEdit: () => _showTerminFormDialog(index: index),
      onDelete: () => _showDeleteTerminDialog(index),
      onStatusChange: (status) => _handleTerminStatusWechsel(index, status),
      onReasonRequiredChange: (value) => _toggleReasonRequired(index, value),
    );
  }

  void _showDeleteTerminDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kCardColor,
          title: Text(
            tr('delete_event'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(tr('confirm_delete_event')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                tr('cancel'),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () {
                setState(() {
                  _allTermine.removeAt(index);
                  _expandedTermine.remove(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(tr('event_deleted'))));
              },
              child: Text(tr('delete_event')),
            ),
          ],
        );
      },
    );
  }

  void _saveTerminFromValueMap(
    Map<String, dynamic> valueMap, {
    int? editIndex,
  }) {
    final startZeit = valueMap['startzeit'] as String;
    final treffZeit = valueMap['treffzeit'] as String;
    final endZeit = valueMap['endzeit'] as String;
    final parsedDateObj = _parseDateTime(
      valueMap['datum'] as String,
      startZeit,
    );
    final normalizedDatum = parsedDateObj != null
        ? _formatDatumForStorage(parsedDateObj)
        : valueMap['datum'] as String;
    final treffpunktText = treffZeit.isNotEmpty ? 'Treffzeit $treffZeit' : '';
    final isSerie = valueMap['isSerie'] == true;
    final wochenAnzahl = (valueMap['wochenAnzahl'] as num?)?.toInt() ?? 1;
    final isEdit = editIndex != null;

    if (isEdit) {
      _allTermine[editIndex] = {
        ..._allTermine[editIndex],
        ...valueMap,
        'datum': normalizedDatum,
        'zeit': startZeit,
        'treffzeit': treffZeit,
        'endzeit': endZeit,
        'untergrund': valueMap['untergrund'],
        'nominierteRollen': valueMap['nominierteRollen'],
        'emailNotification': valueMap['emailNotification'],
        'pushNotification': valueMap['pushNotification'],
        'treffpunkt': treffpunktText,
        'type': _inferTerminType(valueMap['event'] as String),
        'dateObj': parsedDateObj,
      };
      _allTermine[editIndex]['tag'] = _computeWeekdayLabel(
        _allTermine[editIndex]['dateObj'] as DateTime?,
      );
      _allTermine[editIndex]['updatedAt'] = 'Bearbeitet';
      return;
    }

    final startDate = parsedDateObj ?? DateTime.now();
    final iterations = isSerie ? wochenAnzahl : 1;

    for (int i = 0; i < iterations; i++) {
      final currentDate = startDate.add(Duration(days: i * 7));
      final currentDatum = _formatDatumForStorage(currentDate);
      final currentDateObj =
          _parseDateTime(currentDatum, startZeit) ?? currentDate;

      _allTermine.add({
        'tag': _computeWeekdayLabel(currentDateObj),
        'datum': currentDatum,
        'zeit': startZeit,
        'treffzeit': treffZeit,
        'endzeit': endZeit,
        'event': isSerie
            ? '${valueMap['event']} (Serie Woche ${i + 1})'
            : valueMap['event'],
        'type': _inferTerminType(valueMap['event'] as String),
        'status': 'Offen',
        'updatedAt': isSerie ? 'Automatisch erstellt' : 'Erstellt',
        'reasonRequired': valueMap['reasonRequired'],
        'abmeldeGrund': '',
        'treffpunkt': treffpunktText,
        'ort': valueMap['ort'],
        'untergrund': valueMap['untergrund'],
        'nominierteRollen': valueMap['nominierteRollen'],
        'emailNotification': valueMap['emailNotification'],
        'pushNotification': valueMap['pushNotification'],
        'kleidung': '',
        'notiz': valueMap['notiz'] ?? '',
        'teilnehmer': [],
        'dateObj': currentDateObj,
      });
    }
  }

  Future<void> _showKombiniertenTerminPlaner(BuildContext context) async {
    setState(() {
      _selectedIndex = 3;
      _currentTerminSubView = 'select_type';
    });
  }

  Future<void> _showTerminFormDialog({int? index}) async {
    final isEdit = index != null;

    if (isEdit && index >= _allTermine.length) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Termin nicht gefunden.')));
      return;
    }

    final termin = isEdit ? _allTermine[index] : <String, dynamic>{};

    // Controller EINMALIG vor dem Dialog erstellen - KEINE Endlosschleifen!
    final titleCtrl = TextEditingController(
      text: termin['event']?.toString() ?? '',
    );
    final datumCtrl = TextEditingController(
      text: termin['datum']?.toString() ?? '',
    );
    final ortCtrl = TextEditingController(
      text: termin['ort']?.toString() ?? '',
    );
    final notizCtrl = TextEditingController(
      text: termin['notiz']?.toString() ?? '',
    );
    final themenCtrl = TextEditingController(
      text: termin['themen']?.toString() ?? '',
    );

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        // Keine setState Calls im Builder!
        return AlertDialog(
          backgroundColor: kCardColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEdit ? 'Termin bearbeiten' : 'Termin erstellen',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Termin-Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: datumCtrl,
                  decoration: InputDecoration(
                    labelText: 'Datum (TT.MM)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ortCtrl,
                  decoration: InputDecoration(
                    labelText: 'Ort',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notizCtrl,
                  decoration: InputDecoration(
                    labelText: 'Notiz',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: themenCtrl,
                  decoration: InputDecoration(
                    labelText: 'Trainings-Thema / Schwerpunkt',
                    hintText: 'z. B. Ausdauer, Umschaltspiel, Taktik',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.sports_soccer),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty ||
                    datumCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bitte Titel und Datum angeben.'),
                    ),
                  );
                  return;
                }

                if (!mounted) return;

                setState(() {
                  if (isEdit) {
                    _allTermine[index]['event'] = titleCtrl.text.trim();
                    _allTermine[index]['datum'] = datumCtrl.text.trim();
                    _allTermine[index]['ort'] = ortCtrl.text.trim();
                    _allTermine[index]['notiz'] = notizCtrl.text.trim();
                    _allTermine[index]['themen'] = themenCtrl.text.trim();
                  } else {
                    _allTermine.add({
                      'event': titleCtrl.text.trim(),
                      'datum': datumCtrl.text.trim(),
                      'ort': ortCtrl.text.trim(),
                      'notiz': notizCtrl.text.trim(),
                      'themen': themenCtrl.text.trim(),
                      'zeit': '18:00',
                      'tag': 'Montag',
                      'type': 'Training',
                      'status': 'Offen',
                      'teilnehmer': <Map<String, dynamic>>[],
                    });
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEdit ? 'Termin aktualisiert' : 'Termin erstellt',
                    ),
                  ),
                );
              },
              child: Text(isEdit ? 'Speichern' : 'Erstellen'),
            ),
          ],
        );
      },
    );

    // Controller aufräumen nach Dialog
    titleCtrl.dispose();
    datumCtrl.dispose();
    ortCtrl.dispose();
    notizCtrl.dispose();
    themenCtrl.dispose();
  }

  void _zeigeGrundDialog(int index, String status) {
    final TextEditingController reasonController = TextEditingController();
    bool isButtonEnabled = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: kCardColor,
              title: Text(
                tr('justify_status').replaceAll('{status}', status),
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('coach_requires_reason'),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    autofocus: true,
                    maxLength: 100,
                    onChanged: (text) {
                      setDialogState(() {
                        isButtonEnabled = text.trim().length >= 5;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: tr('reason_hint'),
                      hintStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: kPrimaryColor,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white24),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (reasonController.text.trim().length < 5)
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        tr('min_5_chars'),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    tr('cancel'),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                  ),
                  onPressed: isButtonEnabled
                      ? () {
                          _updateTerminStatus(
                            index,
                            status,
                            reasonController.text.trim(),
                          );
                          Navigator.pop(context);
                        }
                      : null,
                  child: Text(
                    tr('save'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTeamFotoEditor(BuildContext context) {
    final TextEditingController captionController = TextEditingController(
      text: _teamPhotoCaption,
    );
    Color selectedColor = _teamPhotoColor;
    Uint8List? selectedImageBytes = _teamPhotoBytes;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: kCardColor,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('edit_team_photo')),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Abbrechen',
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: selectedImageBytes == null
                            ? selectedColor
                            : null,
                        image: selectedImageBytes != null
                            ? DecorationImage(
                                image: MemoryImage(selectedImageBytes!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: selectedImageBytes == null
                          ? const Center(
                              child: Icon(
                                Icons.group,
                                size: 36,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.photo_library),
                            label: Text(tr('choose_photo')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                            ),
                            onPressed: () async {
                              try {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 85,
                                );
                                if (!context.mounted) return;
                                if (picked != null) {
                                  final bytes = await picked.readAsBytes();
                                  if (!context.mounted) return;
                                  setDialogState(() {
                                    selectedImageBytes = bytes;
                                  });
                                }
                              } catch (error) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      kIsWeb
                                          ? 'Bildauswahl wird im Browser nicht zuverlässig unterstützt.'
                                          : 'Fehler bei der Bildauswahl: $error',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        if (selectedImageBytes != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            tooltip: tr('remove_photo'),
                            onPressed: () {
                              setDialogState(() {
                                selectedImageBytes = null;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('choose_bg_color'),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    if (selectedImageBytes == null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildColorPickerCircle(
                            Colors.indigo,
                            selectedColor,
                            () => setDialogState(
                              () => selectedColor = Colors.indigo,
                            ),
                          ),
                          _buildColorPickerCircle(
                            Colors.teal,
                            selectedColor,
                            () => setDialogState(
                              () => selectedColor = Colors.teal,
                            ),
                          ),
                          _buildColorPickerCircle(
                            Colors.deepOrange,
                            selectedColor,
                            () => setDialogState(
                              () => selectedColor = Colors.deepOrange,
                            ),
                          ),
                          _buildColorPickerCircle(
                            Colors.purple,
                            selectedColor,
                            () => setDialogState(
                              () => selectedColor = Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: captionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: tr('image_caption'),
                        labelStyle: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    tr('cancel'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _teamPhotoCaption = captionController.text.trim();
                      _teamPhotoColor = selectedColor;
                      _teamPhotoBytes = selectedImageBytes;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(tr('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showVereinsWappenEditor(BuildContext context) {
    if (!_isVereinsAdmin) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('crest_admin_only'))));
      return;
    }

    Color selectedColor = _vereinsWappenColor;
    Uint8List? selectedImageBytes = _vereinsWappenBytes;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: kCardColor,
              title: Text(tr('edit_crest')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: kDarkBackground,
                        borderRadius: BorderRadius.circular(55),
                        border: Border.all(color: Colors.white24),
                      ),
                      alignment: Alignment.center,
                      child: selectedImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.memory(
                                selectedImageBytes!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : WappenIcon(size: 56, color: selectedColor),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: Text(tr('choose_image')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                      ),
                      onPressed: () async {
                        try {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                          );
                          if (!context.mounted) return;
                          if (picked != null) {
                            final bytes = await picked.readAsBytes();
                            if (!context.mounted) return;
                            setDialogState(() {
                              selectedImageBytes = bytes;
                            });
                          }
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                kIsWeb
                                    ? 'Bildauswahl wird im Browser nicht zuverlässig unterstützt.'
                                    : 'Fehler bei der Bildauswahl: $error',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    if (selectedImageBytes != null)
                      TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            selectedImageBytes = null;
                          });
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        label: Text(
                          tr('remove_image'),
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      tr('choose_crest_color'),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    if (selectedImageBytes == null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildColorPickerCircle(
                            kPrimaryColor,
                            selectedColor,
                            () => setDialogState(
                              () => selectedColor = kPrimaryColor,
                            ),
                          ),
                          _buildColorPickerCircle(
                            Colors.green,
                            selectedColor,
                            () => setDialogState(
                              () => selectedColor = Colors.green,
                            ),
                          ),
                          _buildColorPickerCircle(
                            Colors.blue,
                            selectedColor,
                            () => setDialogState(
                              () => selectedColor = Colors.blue,
                            ),
                          ),
                          _buildColorPickerCircle(
                            Colors.orange,
                            selectedColor,
                            () => setDialogState(
                              () => selectedColor = Colors.orange,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    tr('cancel'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _vereinsWappenColor = selectedColor;
                      _vereinsWappenBytes = selectedImageBytes;
                    });
                    _saveVereinsWappenSettings();
                    Navigator.pop(context);
                  },
                  child: Text(tr('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildColorPickerCircle(
    Color option,
    Color selectedColor,
    VoidCallback onSelected,
  ) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: option,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == option ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  void _zeigeTeilnehmerListe(int index) {
    final termin = _allTermine[index];
    final List<dynamic> allTeilnehmer = termin['teilnehmer'] ?? [];

    final zusagenListe = allTeilnehmer
        .where((t) => t['status'] == 'Zusage')
        .toList();
    final unsicherListe = allTeilnehmer
        .where((t) => t['status'] == 'Unsicher')
        .toList();
    final absagenListe = allTeilnehmer
        .where((t) => t['status'] == 'Absage')
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kCardColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                termin['event'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr('squad_availability'),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: allTeilnehmer.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      tr('no_feedback_yet'),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildKategorieHeader(
                          tr('registered_count').replaceAll(
                            '{count}',
                            zusagenListe.length.toString(),
                          ),
                          Colors.green,
                        ),
                        if (zusagenListe.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 8.0, bottom: 15),
                            child: Text(
                              tr('no_confirmations'),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          )
                        else
                          ...zusagenListe.map(
                            (spieler) => _buildTeilnehmerTile(
                              spieler,
                              Colors.green,
                              Icons.check_circle_outline,
                            ),
                          ),
                        const SizedBox(height: 10),
                        const Divider(color: Colors.white10),
                        _buildKategorieHeader(
                          tr('uncertain_count').replaceAll(
                            '{count}',
                            unsicherListe.length.toString(),
                          ),
                          Colors.orange,
                        ),
                        if (unsicherListe.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 8.0, bottom: 15),
                            child: Text(
                              tr('no_uncertain_feedback'),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          )
                        else
                          ...unsicherListe.map(
                            (spieler) => _buildTeilnehmerTile(
                              spieler,
                              Colors.orange,
                              Icons.help_outline,
                            ),
                          ),
                        const SizedBox(height: 10),
                        const Divider(color: Colors.white10),
                        _buildKategorieHeader(
                          tr('canceled_count').replaceAll(
                            '{count}',
                            absagenListe.length.toString(),
                          ),
                          Colors.red,
                        ),
                        if (absagenListe.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 8.0, bottom: 15),
                            child: Text(
                              tr('no_cancellations'),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          )
                        else
                          ...absagenListe.map(
                            (spieler) => _buildTeilnehmerTile(
                              spieler,
                              Colors.red,
                              Icons.highlight_off,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                tr('close'),
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKategorieHeader(String titel, Color farbe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: farbe.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          titel,
          style: TextStyle(
            color: farbe,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildTeilnehmerTile(dynamic spieler, Color farbe, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Card(
        color: kDarkBackground,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          dense: true,
          leading: Icon(icon, color: farbe, size: 20),
          title: Text(
            spieler['name'],
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: spieler['grund'].toString().isNotEmpty
              ? Text(
                  'Grund: "${spieler['grund']}"',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
        ),
      ),
    );
  }

  void _showSpielerImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: Text(
          tr('import_members'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: SizedBox(
          width: adaptiveDialogWidth(context),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.file_upload, color: Colors.green),
                  title: Text(
                    tr('import_excel_csv'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.orange),
                  title: Text(
                    tr('enter_players_manually'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                if (_canApproveAccounts)
                  ListTile(
                    leading: const Icon(
                      Icons.verified_user,
                      color: Colors.greenAccent,
                    ),
                    title: const Text(
                      'Konten verknüpfen / Freigeben',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentWappenSubView = 'account_linking';
                      });
                    },
                  ),
                if (_canApproveAccounts)
                  ListTile(
                    leading: const Icon(
                      Icons.history,
                      color: Colors.lightBlueAccent,
                    ),
                    title: const Text(
                      'Freigabe-Protokoll anzeigen',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentWappenSubView = 'approval_audit';
                      });
                    },
                  ),
                if (_isCoachOrAdmin)
                  ListTile(
                    leading: const Icon(
                      Icons.upload_file,
                      color: Colors.greenAccent,
                    ),
                    title: const Text(
                      'DFBnet-Import Assistent',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentWappenSubView = 'dfbnet_import';
                      });
                    },
                  ),
                if (_isCoachOrAdmin)
                  ListTile(
                    leading: const Icon(
                      Icons.person_add_alt_1,
                      color: Colors.amberAccent,
                    ),
                    title: const Text(
                      'Neues Profil anlegen',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentWappenSubView = 'create_user';
                      });
                    },
                  ),
                if (_hasRole('Vereinsadministrator'))
                  ListTile(
                    leading: const Icon(
                      Icons.group_add,
                      color: Colors.blueAccent,
                    ),
                    title: const Text(
                      'Spieler einem Team zuweisen',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showAssignMemberTeamsDialog();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TerminCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> termin;
  final bool isExpanded;
  final bool isCoachOrAdmin;
  final VoidCallback onToggleExpand;
  final VoidCallback onShowTeilnehmer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(String status) onStatusChange;
  final void Function(bool value) onReasonRequiredChange;

  const TerminCard({
    super.key,
    required this.index,
    required this.termin,
    required this.isExpanded,
    required this.isCoachOrAdmin,
    required this.onToggleExpand,
    required this.onShowTeilnehmer,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChange,
    required this.onReasonRequiredChange,
  });

  @override
  Widget build(BuildContext context) {
    String t(String key) => AppI18n.of(context).t(key);
    final eventName = termin['event']?.toString() ?? 'Unbenannter Termin';
    final weekday = termin['tag']?.toString() ?? '??';
    final treffpunktRaw = termin['treffpunkt']?.toString().trim() ?? '';
    final treffenZeit = treffpunktRaw.isEmpty ? '-:-' : treffpunktRaw;
    final beginnZeit = termin['zeit']?.toString() ?? '-:-';
    final endeZeit = (termin['endzeit']?.toString().trim().isNotEmpty ?? false)
        ? termin['endzeit'].toString()
        : '12:30';

    final teilnehmer =
        (termin['teilnehmer'] as List?)
            ?.whereType<Map>()
            .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
            .toList() ??
        <Map<String, dynamic>>[];
    final zusagenCount = teilnehmer
        .where((t) => t['status']?.toString() == 'Zusage')
        .length;
    final unsicherCount = teilnehmer
        .where((t) => t['status']?.toString() == 'Unsicher')
        .length;
    final absagenCount = teilnehmer
        .where((t) => t['status']?.toString() == 'Absage')
        .length;
    final myStatus =
        teilnehmer
            .firstWhere(
              (t) => (t['name']?.toString() ?? '') == 'Du (Eigener Account)',
              orElse: () => <String, dynamic>{},
            )['status']
            ?.toString() ??
        '';

    final matchId = termin['matchId']?.toString().trim() ?? '';
    final score = termin['score']?.toString().trim() ?? '';
    final competition = termin['competition']?.toString().trim() ?? '';
    final referee = termin['referee']?.toString().trim() ?? '';
    final updatedAt = termin['updatedAt']?.toString().trim() ?? '';
    final bool isLiveImportedMatch =
        matchId.isNotEmpty ||
        score.isNotEmpty ||
        competition.isNotEmpty ||
        referee.isNotEmpty;

    final rawDatum = termin['datum']?.toString() ?? '??.??';
    final split = rawDatum.split('.').where((p) => p.isNotEmpty).toList();
    final shortDatum = split.length >= 2
        ? '${split[0].padLeft(2, '0')}.${split[1].padLeft(2, '0')}'
        : rawDatum;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: kDarkBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLiveImportedMatch
                ? Colors.greenAccent.withValues(alpha: 0.5)
                : kBorderColor,
          ),
          boxShadow: isLiveImportedMatch
              ? [
                  BoxShadow(
                    color: Colors.greenAccent.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onToggleExpand,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 62,
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kDarkBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$weekday.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$shortDatum.',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        eventName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isLiveImportedMatch)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Text(
                          'Live',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (isLiveImportedMatch) const SizedBox(width: 8),
                    if (score.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          score,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (score.isNotEmpty) const SizedBox(width: 8),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: kCardColor,
                border: Border(
                  top: BorderSide(color: Colors.white10),
                  bottom: BorderSide(color: Colors.white10),
                ),
              ),
              child: Row(
                children: [
                  _buildZeitSegment(t('meeting_label'), treffenZeit),
                  _buildVerticalDivider(),
                  _buildZeitSegment(t('start_label'), beginnZeit),
                  _buildVerticalDivider(),
                  _buildZeitSegment(t('end_label'), endeZeit),
                ],
              ),
            ),
            if (isExpanded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: const BoxDecoration(
                  color: kBackgroundColor,
                  border: Border(bottom: BorderSide(color: Colors.white10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (matchId.isNotEmpty ||
                        competition.isNotEmpty ||
                        updatedAt.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (matchId.isNotEmpty)
                            _buildDetailChip(
                              Icons.confirmation_number_outlined,
                              'Spielnummer',
                              matchId,
                            ),
                          if (competition.isNotEmpty)
                            _buildDetailChip(
                              Icons.emoji_events_outlined,
                              'Wettbewerb',
                              competition,
                            ),
                          if (updatedAt.isNotEmpty)
                            _buildDetailChip(
                              Icons.sync,
                              'Aktualisiert',
                              updatedAt,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    _buildDetailLine(
                      Icons.location_on,
                      t('place_label'),
                      termin['ort']?.toString().trim().isNotEmpty == true
                          ? termin['ort'].toString().trim()
                          : t('not_specified'),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailLine(
                      Icons.notes,
                      t('note_detail_label'),
                      termin['notiz']?.toString().trim().isNotEmpty == true
                          ? termin['notiz'].toString().trim()
                          : t('no_note_available'),
                    ),
                    if (termin['themen']?.toString().trim().isNotEmpty ==
                        true) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.sports_soccer,
                              size: 20,
                              color: Colors.orangeAccent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children:
                                    (termin['themen']?.toString().split(',') ??
                                            [])
                                        .map(
                                          (theme) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orangeAccent
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.orangeAccent
                                                    .withValues(alpha: 0.4),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Text(
                                              theme.trim(),
                                              style: const TextStyle(
                                                color: Colors.orangeAccent,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (referee.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailLine(Icons.sports, 'Schiedsrichter', referee),
                    ],
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: kDarkBackground,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildStatusCounter(
                        icon: Icons.thumb_up_alt,
                        color: Colors.greenAccent,
                        value: zusagenCount,
                      ),
                      const SizedBox(width: 14),
                      _buildStatusCounter(
                        icon: Icons.help_outline,
                        color: Colors.orangeAccent,
                        value: unsicherCount,
                      ),
                      const SizedBox(width: 14),
                      _buildStatusCounter(
                        icon: Icons.thumb_down_alt,
                        color: Colors.redAccent,
                        value: absagenCount,
                      ),
                      const Spacer(),
                      if (isCoachOrAdmin)
                        IconButton(
                          onPressed: onEdit,
                          splashRadius: 20,
                          tooltip: 'Termin bearbeiten',
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      if (isCoachOrAdmin)
                        IconButton(
                          onPressed: onDelete,
                          splashRadius: 20,
                          tooltip: t('delete_appointment_tooltip'),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                        ),
                      IconButton(
                        onPressed: onShowTeilnehmer,
                        splashRadius: 20,
                        tooltip: t('view_participants_tooltip'),
                        icon: const Icon(
                          Icons.visibility,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatusActionButton(
                        icon: Icons.thumb_up_alt,
                        label: t('join_action'),
                        color: Colors.greenAccent,
                        selected: myStatus == 'Zusage',
                        onTap: () => onStatusChange('Zusage'),
                      ),
                      _buildStatusActionButton(
                        icon: Icons.help_outline,
                        label: t('unsure_action'),
                        color: Colors.orangeAccent,
                        selected: myStatus == 'Unsicher',
                        onTap: () => onStatusChange('Unsicher'),
                      ),
                      _buildStatusActionButton(
                        icon: Icons.thumb_down_alt,
                        label: t('decline_action'),
                        color: Colors.redAccent,
                        selected: myStatus == 'Absage',
                        onTap: () => onStatusChange('Absage'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: kBorderColor,
    );
  }

  Widget _buildZeitSegment(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCounter({
    required IconData icon,
    required Color color,
    required int value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailLine(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AbstimmungErstellenDialog extends StatefulWidget {
  final void Function(
    String titel,
    bool allowMultipleAnswers,
    List<Map<String, dynamic>> optionen,
  )
  onCreate;

  const _AbstimmungErstellenDialog({required this.onCreate});

  @override
  State<_AbstimmungErstellenDialog> createState() =>
      _AbstimmungErstellenDialogState();
}

class _AbstimmungErstellenDialogState
    extends State<_AbstimmungErstellenDialog> {
  final TextEditingController _titelController = TextEditingController();
  final List<TextEditingController> _optionenControllers =
      <TextEditingController>[
        TextEditingController(text: 'Ja'),
        TextEditingController(text: 'Nein'),
      ];
  bool _allowMultipleAnswers = false;

  String tr(String key) => AppI18n.of(context).t(key);

  @override
  void dispose() {
    _titelController.dispose();
    for (final controller in _optionenControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _canCreateVote {
    final hasTitle = _titelController.text.trim().isNotEmpty;
    int validOptions = 0;
    for (final controller in _optionenControllers) {
      if (controller.text.trim().isNotEmpty) {
        validOptions++;
      }
    }
    return hasTitle && validOptions >= 2;
  }

  void _submit() {
    final titel = _titelController.text.trim();
    final List<Map<String, dynamic>> neueOptionen = [];
    for (var controller in _optionenControllers) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        neueOptionen.add({'text': text, 'stimmen': 0, 'votedUsers': []});
      }
    }

    if (titel.isEmpty || neueOptionen.length < 2) {
      return;
    }

    widget.onCreate(titel, _allowMultipleAnswers, neueOptionen);
    Navigator.pop(context);
  }

  Widget _buildOptionField(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: _optionenControllers[index],
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: 'Option ${index + 1}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kCardColor,
      title: Text(tr('create_vote')),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titelController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: tr('question_title')),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _optionenControllers.length,
                itemBuilder: (context, index) => _buildOptionField(index),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _optionenControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('+ Option hinzufügen'),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mehrfachauswahl erlauben'),
                value: _allowMultipleAnswers,
                onChanged: (value) =>
                    setState(() => _allowMultipleAnswers = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(tr('cancel')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: _canCreateVote ? _submit : null,
          child: Text(tr('create')),
        ),
      ],
    );
  }
}

class TerminFormDialog extends StatefulWidget {
  final bool isEdit;
  final bool allowSeries;
  final Map<String, dynamic>? initialValues;
  final void Function(Map<String, dynamic> valueMap) onSave;
  final bool fullscreenMode;
  final VoidCallback? onBack;
  final String? pageTitle;

  const TerminFormDialog({
    super.key,
    required this.isEdit,
    this.allowSeries = false,
    required this.initialValues,
    required this.onSave,
    this.fullscreenMode = false,
    this.onBack,
    this.pageTitle,
  });

  @override
  State<TerminFormDialog> createState() => _TerminFormDialogState();
}

class _TerminFormDialogState extends State<TerminFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _datumController;
  late final TextEditingController _startZeitController;
  late final TextEditingController _treffZeitController;
  late final TextEditingController _endZeitController;
  late final TextEditingController _ortController;
  late final TextEditingController _notizController;
  late final TextEditingController _themenController;

  final List<String> _untergrundOptionen = const [
    'Rasen',
    'Halle',
    'Kunstrasen',
    'Asche',
    'Wald',
    'Straße',
    'Laufbahn',
    'Sand',
    'Eisfläche',
    'Wasser',
  ];

  final List<String> _rollenOptionen = const [
    'Trainer',
    'Betreuer',
    'Kassenwart',
    'Spieler',
    'Inaktiv',
  ];

  late String _ausgewaehlterUntergrund;
  Set<String> _nominierteRollen = {'Spieler'};
  bool _rollenManuellGeaendert = false;
  bool _emailBenachrichtigung = false;
  bool _pushBenachrichtigung = true;
  bool _isSerie = false;
  int _wochenAnzahl = 4;
  bool _grundPflicht = false;
  bool _zeitfolgeValid = true;
  bool _isValid = false;

  String tr(String key) {
    return AppI18n.of(context).t(key);
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialValues?['event']?.toString() ?? '',
    );
    _datumController = TextEditingController(
      text: widget.initialValues?['datum']?.toString() ?? '',
    );
    _startZeitController = TextEditingController(
      text: widget.initialValues?['zeit']?.toString() ?? '18:00',
    );
    _treffZeitController = TextEditingController(
      text: widget.initialValues?['treffzeit']?.toString() ?? '',
    );
    _endZeitController = TextEditingController(
      text: widget.initialValues?['endzeit']?.toString() ?? '',
    );
    _ortController = TextEditingController(
      text: widget.initialValues?['ort']?.toString() ?? '',
    );
    _notizController = TextEditingController(
      text: widget.initialValues?['notiz']?.toString() ?? '',
    );
    _themenController = TextEditingController(
      text: widget.initialValues?['themen']?.toString() ?? '',
    );

    final initialUntergrund = widget.initialValues?['untergrund']?.toString();
    _ausgewaehlterUntergrund = _untergrundOptionen.contains(initialUntergrund)
        ? initialUntergrund!
        : _untergrundOptionen.first;

    final initialRollen = (widget.initialValues?['nominierteRollen'] as List?)
        ?.map((e) => e.toString())
        .where((e) => _rollenOptionen.contains(e))
        .toSet();
    if (initialRollen != null && initialRollen.isNotEmpty) {
      _nominierteRollen = initialRollen;
      _rollenManuellGeaendert = true;
    }

    if (widget.isEdit) {
      _rollenManuellGeaendert = true;
    }

    _emailBenachrichtigung = widget.initialValues?['emailNotification'] == true;
    _pushBenachrichtigung = widget.initialValues?['pushNotification'] != false;
    _isSerie = widget.allowSeries && widget.initialValues?['isSerie'] == true;
    _wochenAnzahl =
        (widget.initialValues?['wochenAnzahl'] as num?)?.toInt() ?? 4;
    if (![2, 4, 6, 8, 12].contains(_wochenAnzahl)) {
      _wochenAnzahl = 4;
    }
    _grundPflicht = widget.initialValues?['reasonRequired'] ?? false;

    _validateForm();
    _nameController.addListener(_handleEventNameChanged);
    _nameController.addListener(_validateForm);
    _datumController.addListener(_validateForm);
    _startZeitController.addListener(_validateForm);
    _treffZeitController.addListener(_validateForm);
    _endZeitController.addListener(_validateForm);
    _ortController.addListener(_validateForm);
    _themenController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _datumController.dispose();
    _startZeitController.dispose();
    _treffZeitController.dispose();
    _endZeitController.dispose();
    _ortController.dispose();
    _notizController.dispose();
    _themenController.dispose();
    super.dispose();
  }

  void _handleEventNameChanged() {
    if (_rollenManuellGeaendert) return;
    final preset = _defaultRollenForEvent(_nameController.text);
    if (preset.length == _nominierteRollen.length &&
        preset.containsAll(_nominierteRollen)) {
      return;
    }
    setState(() {
      _nominierteRollen = preset;
    });
  }

  Set<String> _defaultRollenForEvent(String eventName) {
    final lower = eventName.toLowerCase();
    if (lower.contains('spiel') ||
        lower.contains('testspiel') ||
        lower.contains('pokal') ||
        lower.contains('freundschaft')) {
      return {'Trainer', 'Betreuer', 'Spieler'};
    }
    if (lower.contains('training')) {
      return {'Trainer', 'Betreuer', 'Spieler'};
    }
    return {'Trainer', 'Betreuer', 'Kassenwart'};
  }

  void _validateForm() {
    final eventValid = _nameController.text.trim().isNotEmpty;
    final datumValid = _validateDatum(_datumController.text.trim());
    final startValid = _validateZeit(_startZeitController.text.trim());
    final treffValid = _validateOptionaleZeit(_treffZeitController.text.trim());
    final endValid = _validateOptionaleZeit(_endZeitController.text.trim());
    final zeitfolgeValid = _validateZeitfolge(
      _startZeitController.text.trim(),
      _endZeitController.text.trim(),
    );
    final ortValid = _ortController.text.trim().isNotEmpty;
    setState(() {
      _zeitfolgeValid = zeitfolgeValid;
      _isValid =
          eventValid &&
          datumValid &&
          startValid &&
          treffValid &&
          endValid &&
          zeitfolgeValid &&
          ortValid;
    });
  }

  int? _zeitInMinuten(String zeit) {
    if (!_validateZeit(zeit)) return null;
    final parts = zeit.split(':');
    final hour = int.tryParse(parts[0].trim());
    final minute = int.tryParse(parts[1].trim());
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  bool _validateZeitfolge(String startzeit, String endzeit) {
    if (endzeit.isEmpty) return true;
    final startMin = _zeitInMinuten(startzeit);
    final endMin = _zeitInMinuten(endzeit);
    if (startMin == null || endMin == null) return true;
    return endMin > startMin;
  }

  bool _validateDatum(String datum) {
    final cleaned = datum.replaceAll(' ', '');
    final parts = cleaned.split('.').where((p) => p.isNotEmpty).toList();
    if (parts.length < 2 || parts.length > 3) return false;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = parts.length == 3 ? int.tryParse(parts[2]) : null;
    if (day == null || month == null) return false;
    if (parts.length == 3 && year == null) return false;

    try {
      DateTime(year ?? DateTime.now().year, month, day);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _validateZeit(String zeit) {
    final parts = zeit.split(':');
    if (parts.length != 2) return false;
    final hour = int.tryParse(parts[0].trim());
    final minute = int.tryParse(parts[1].trim());
    if (hour == null || minute == null) return false;
    return hour >= 0 && hour < 24 && minute >= 0 && minute < 60;
  }

  bool _validateOptionaleZeit(String zeit) {
    if (zeit.trim().isEmpty) return true;
    return _validateZeit(zeit.trim());
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_datumController.text.isNotEmpty) {
      final cleaned = _datumController.text.replaceAll(' ', '');
      final parts = cleaned.split('.').where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = parts.length >= 3
            ? int.tryParse(parts[2])
            : DateTime.now().year;
        if (d != null && m != null && y != null) {
          try {
            initialDate = DateTime(y, m, d);
          } catch (_) {
            initialDate = DateTime.now();
          }
        }
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              surface: kCardColor,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: kCardColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _datumController.text =
            '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}';
      });
      _validateForm();
    }
  }

  Future<void> _selectTimeForController(
    BuildContext context,
    TextEditingController controller,
  ) async {
    TimeOfDay initialTime = const TimeOfDay(hour: 18, minute: 0);
    if (controller.text.isNotEmpty) {
      final parts = controller.text.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null) {
          initialTime = TimeOfDay(hour: h, minute: m);
        }
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              surface: kCardColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
      _validateForm();
    }
  }

  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white10,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: kPrimaryColor),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white12),
      ),
    );
  }

  Widget _buildFormSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formContent = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormSection(
            title: 'Basis-Infos',
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: _buildInputDecoration(
                    label: tr('event_name_required'),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _datumController,
                  decoration: _buildInputDecoration(
                    label: tr('date_required'),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.calendar_month,
                        color: kPrimaryColor,
                      ),
                      onPressed: () => _selectDate(context),
                      tooltip: tr('open_calendar'),
                    ),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildFormSection(
            title: 'Zeiten',
            child: LayoutBuilder(
              builder: (context, constraints) {
                Widget buildTimeField({
                  required TextEditingController controller,
                  required String label,
                  required Widget suffixIcon,
                }) {
                  return TextField(
                    controller: controller,
                    decoration: _buildInputDecoration(
                      label: label,
                      suffixIcon: suffixIcon,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.datetime,
                  );
                }

                Widget buildCompactIcon(
                  IconData icon,
                  String tooltip,
                  VoidCallback onPressed,
                ) {
                  return IconButton(
                    icon: Icon(icon, color: kPrimaryColor, size: 18),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 32,
                      height: 32,
                    ),
                    onPressed: onPressed,
                    tooltip: tooltip,
                  );
                }

                if (constraints.maxWidth < 720) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: buildTimeField(
                              controller: _startZeitController,
                              label: tr('start_time_required'),
                              suffixIcon: buildCompactIcon(
                                Icons.access_time,
                                tr('select_time'),
                                () => _selectTimeForController(
                                  context,
                                  _startZeitController,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: buildTimeField(
                              controller: _endZeitController,
                              label: tr('end_time_optional'),
                              suffixIcon: buildCompactIcon(
                                Icons.timer_outlined,
                                tr('select_end_time'),
                                () => _selectTimeForController(
                                  context,
                                  _endZeitController,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      buildTimeField(
                        controller: _treffZeitController,
                        label: tr('meeting_time_optional'),
                        suffixIcon: buildCompactIcon(
                          Icons.schedule,
                          tr('select_meeting_time'),
                          () => _selectTimeForController(
                            context,
                            _treffZeitController,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: buildTimeField(
                        controller: _startZeitController,
                        label: tr('start_time_required'),
                        suffixIcon: buildCompactIcon(
                          Icons.access_time,
                          tr('select_time'),
                          () => _selectTimeForController(
                            context,
                            _startZeitController,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildTimeField(
                        controller: _treffZeitController,
                        label: tr('meeting_time_optional'),
                        suffixIcon: buildCompactIcon(
                          Icons.schedule,
                          tr('select_meeting_time'),
                          () => _selectTimeForController(
                            context,
                            _treffZeitController,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildTimeField(
                        controller: _endZeitController,
                        label: tr('end_time_optional'),
                        suffixIcon: buildCompactIcon(
                          Icons.timer_outlined,
                          tr('select_end_time'),
                          () => _selectTimeForController(
                            context,
                            _endZeitController,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          _buildFormSection(
            title: 'Ort & Untergrund',
            child: Column(
              children: [
                TextField(
                  controller: _ortController,
                  decoration: _buildInputDecoration(
                    label: tr('sports_facility_required'),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _ausgewaehlterUntergrund,
                      isExpanded: true,
                      dropdownColor: kCardColor,
                      items: _untergrundOptionen
                          .map(
                            (option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _ausgewaehlterUntergrund = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _notizController,
                  decoration: _buildInputDecoration(label: tr('note_label')),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _themenController,
                  decoration: _buildInputDecoration(
                    label: 'Trainings-Thema / Schwerpunkt',
                    hint: 'z. B. Ausdauer, Umschaltspiel, Taktik',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildFormSection(
            title: 'Organisation & Benachrichtigungen',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.allowSeries) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tr('series_event_label'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Switch(
                        value: _isSerie,
                        activeThumbColor: kPrimaryColor,
                        onChanged: (value) => setState(() {
                          _isSerie = value;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (_isSerie)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _wochenAnzahl,
                          isExpanded: true,
                          dropdownColor: kCardColor,
                          items: [2, 4, 6, 8, 12]
                              .map(
                                (w) => DropdownMenuItem<int>(
                                  value: w,
                                  child: Text(
                                    tr(
                                      'duration_weeks',
                                    ).replaceAll('{weeks}', w.toString()),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _wochenAnzahl = value;
                            });
                          },
                        ),
                      ),
                    ),
                  if (_isSerie) const SizedBox(height: 18),
                ],
                Text(
                  tr('nominate_roles'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _rollenOptionen.map((rolle) {
                    final selected = _nominierteRollen.contains(rolle);
                    return FilterChip(
                      label: Text(rolle),
                      selected: selected,
                      selectedColor: kPrimaryColor.withValues(alpha: 0.25),
                      checkmarkColor: Colors.white,
                      onSelected: (value) {
                        setState(() {
                          _rollenManuellGeaendert = true;
                          if (value) {
                            _nominierteRollen.add(rolle);
                          } else {
                            _nominierteRollen.remove(rolle);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Material(
                  color: Colors.transparent,
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(tr('email_notify')),
                    value: _emailBenachrichtigung,
                    onChanged: (value) {
                      setState(() {
                        _emailBenachrichtigung = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Material(
                  color: Colors.transparent,
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(tr('push_notify')),
                    value: _pushBenachrichtigung,
                    onChanged: (value) {
                      setState(() {
                        _pushBenachrichtigung = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr('reason_required_cancel')),
                    Switch(
                      value: _grundPflicht,
                      activeThumbColor: kPrimaryColor,
                      onChanged: (value) => setState(() {
                        _grundPflicht = value;
                      }),
                    ),
                  ],
                ),
                if (!_isValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Text(
                      _zeitfolgeValid
                          ? tr('fill_required_correctly')
                          : tr('end_must_be_after_start'),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    final actions = [
      TextButton(
        onPressed: () {
          if (widget.fullscreenMode) {
            widget.onBack?.call();
          } else {
            Navigator.pop(context);
          }
        },
        child: Text(tr('cancel'), style: const TextStyle(color: Colors.white)),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
        onPressed: _isValid
            ? () {
                final valueMap = {
                  'event': _nameController.text.trim(),
                  'datum': _datumController.text.trim(),
                  'startzeit': _startZeitController.text.trim(),
                  'treffzeit': _treffZeitController.text.trim(),
                  'endzeit': _endZeitController.text.trim(),
                  'ort': _ortController.text.trim(),
                  'untergrund': _ausgewaehlterUntergrund,
                  'nominierteRollen': _nominierteRollen.toList(),
                  'emailNotification': _emailBenachrichtigung,
                  'pushNotification': _pushBenachrichtigung,
                  'isSerie': widget.allowSeries ? _isSerie : false,
                  'wochenAnzahl': widget.allowSeries ? _wochenAnzahl : 1,
                  'notiz': _notizController.text.trim(),
                  'themen': _themenController.text.trim(),
                  'reasonRequired': _grundPflicht,
                };
                widget.onSave(valueMap);
              }
            : null,
        child: Text(widget.isEdit ? tr('save') : tr('create')),
      ),
    ];

    if (widget.fullscreenMode) {
      return Container(
        color: kBackgroundColor,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      widget.pageTitle ??
                          (widget.isEdit
                              ? tr('edit_event_form')
                              : tr('new_event_form')),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: formContent),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ),
          ],
        ),
      );
    }

    return AlertDialog(
      backgroundColor: kCardColor,
      title: Text(widget.isEdit ? tr('edit_event_form') : tr('new_event_form')),
      content: formContent,
      actions: actions,
    );
  }
}

class WappenIcon extends StatelessWidget {
  final double size;
  final Color color;

  const WappenIcon({super.key, this.size = 24, this.color = kPrimaryColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _WappenIconPainter(color: color)),
    );
  }
}

class _WappenIconPainter extends CustomPainter {
  final Color color;

  _WappenIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final shieldPath = Path()
      ..moveTo(size.width * 0.5, 0)
      ..arcToPoint(
        Offset(size.width * 0.1, size.height * 0.25),
        radius: Radius.circular(size.width * 0.25),
        clockwise: false,
      )
      ..lineTo(size.width * 0.1, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.85,
        size.width * 0.5,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.85,
        size.width * 0.9,
        size.height * 0.55,
      )
      ..lineTo(size.width * 0.9, size.height * 0.25)
      ..arcToPoint(
        Offset(size.width * 0.5, 0),
        radius: Radius.circular(size.width * 0.25),
        clockwise: false,
      )
      ..close();

    canvas.drawPath(shieldPath, paint);

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final headCenter = Offset(size.width * 0.52, size.height * 0.32);
    canvas.drawCircle(headCenter, size.width * 0.08, innerPaint);

    final bodyPath = Path()
      ..moveTo(size.width * 0.42, size.height * 0.4)
      ..lineTo(size.width * 0.58, size.height * 0.4)
      ..lineTo(size.width * 0.54, size.height * 0.58)
      ..lineTo(size.width * 0.46, size.height * 0.58)
      ..close();
    canvas.drawPath(bodyPath, innerPaint);

    final stemPath = Path()
      ..moveTo(size.width * 0.32, size.height * 0.48)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.35,
        size.width * 0.42,
        size.height * 0.3,
      )
      ..lineTo(size.width * 0.44, size.height * 0.32)
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.35,
        size.width * 0.34,
        size.height * 0.45,
      )
      ..close();
    canvas.drawPath(stemPath, innerPaint);

    final leafPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.24, size.height * 0.3),
        width: size.width * 0.16,
        height: size.height * 0.12,
      ),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.28, size.height * 0.2),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      leafPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
