extends Node
## Android-only provider. No editor mock ads and no ad requests on desktop.
signal phase(value: String)
signal reward
signal closed
signal failed
var active := true
var under_age_of_consent := true
var test_ads := true
var unit_id := ""
var ad: RewardedAd
var loader: RewardedAdLoader
var form: ConsentForm
var initialized := false

func begin(test: bool, id: String) -> void:
	test_ads=test; unit_id=id
	# Google's demo ad units do not monetize; live traffic always requires UMP.
	if test_ads: initialize_ads(); return
	var params := ConsentRequestParameters.new()
	params.tag_for_under_age_of_consent=under_age_of_consent
	UserMessagingPlatform.consent_information.update(params,consent_updated,consent_failed)

func consent_updated() -> void:
	if not active: return
	var info=UserMessagingPlatform.consent_information
	if info.get_consent_status()==ConsentInformation.ConsentStatus.REQUIRED:
		UserMessagingPlatform.load_consent_form(consent_loaded,consent_failed)
	else: consent_finished(null)

func consent_loaded(value: ConsentForm) -> void:
	if not active: return
	form=value; form.show(consent_finished)

func consent_allowed() -> bool:
	return UserMessagingPlatform.consent_information.get_consent_status() in [ConsentInformation.ConsentStatus.NOT_REQUIRED,ConsentInformation.ConsentStatus.OBTAINED]

func consent_finished(_error) -> void:
	if not active: return
	if consent_allowed(): initialize_ads()
	else: failed.emit()

func consent_failed(_error) -> void:
	# Prior session consent may still be valid after an update/network failure.
	consent_finished(_error)

func initialize_ads() -> void:
	if not active or initialized: return
	initialized=true; phase.emit("loading")
	var config := RequestConfiguration.new()
	config.tag_for_child_directed_treatment=RequestConfiguration.TagForChildDirectedTreatment.FALSE
	config.tag_for_under_age_of_consent=RequestConfiguration.TagForUnderAgeOfConsent.TRUE if under_age_of_consent else RequestConfiguration.TagForUnderAgeOfConsent.FALSE
	config.max_ad_content_rating=RequestConfiguration.MAX_AD_CONTENT_RATING_G
	MobileAds.set_request_configuration(config)
	MobileAds.set_publisher_first_party_id_enabled(false)
	var listener := OnInitializationCompleteListener.new()
	listener.on_initialization_complete=load_ad
	MobileAds.initialize(listener)

func load_ad(_status) -> void:
	if not active: return
	if not test_ads and not consent_allowed(): failed.emit(); return
	var callbacks := RewardedAdLoadCallback.new()
	callbacks.on_ad_loaded=ad_loaded
	callbacks.on_ad_failed_to_load=func(_error):
		if active: failed.emit()
	loader=RewardedAdLoader.new()
	loader.load(unit_id,AdRequest.new(),callbacks)

func ad_loaded(value: RewardedAd) -> void:
	if not active: value.destroy(); return
	ad=value
	var callbacks := FullScreenContentCallback.new()
	callbacks.on_ad_dismissed_full_screen_content=func():
		if active: closed.emit()
	callbacks.on_ad_failed_to_show_full_screen_content=func(_error):
		if active: failed.emit()
	ad.full_screen_content_callback=callbacks
	var listener := OnUserEarnedRewardListener.new()
	listener.on_user_earned_reward=func(_item):
		if active: reward.emit()
	phase.emit("showing")
	ad.show(listener)

func stop() -> void:
	active=false
	if ad!=null: ad.destroy(); ad=null

static func privacy_required() -> bool:
	return OS.get_name()=="Android" and Engine.has_singleton("PoingGodotAdMobUserMessagingPlatform") and UserMessagingPlatform.consent_information.get_privacy_options_requirement_status()==ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED

static func show_privacy(callback: Callable) -> void:
	UserMessagingPlatform.show_privacy_options_form(callback)
