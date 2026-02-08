-- AudioExtrasDemo — demonstrates gap-fill Audio/Acodec APIs.
-- Console-only — no display needed.
--
-- Showcases: createSample, getSampleData, saveSample, stopSample,
--            identifySample, getSample, setSample,
--            getSampleInstanceFrequency, getSampleInstanceAttached,
--            getSampleInstanceChannels, getSampleInstanceDepth,
--            getSampleInstanceTime, setSampleInstanceLength,
--            attachSampleInstanceToVoice,
--            createAudioStream, getAudioStreamFrequency,
--            getAudioStreamLength, getAudioStreamFragments,
--            getAvailableAudioStreamFragments, getAudioStreamChannels,
--            getAudioStreamDepth, getAudioStreamAttached,
--            getAudioStreamPlayedSamples, getAudioStreamFragment,
--            setAudioStreamFragment, attachAudioStreamToVoice,
--            getMixerChannels, getMixerDepth, getMixerAttached,
--            mixerHasAttachments, getVoicePosition, getVoiceChannels,
--            getVoiceDepth, setVoicePosition, voiceHasAttachments,
--            setDefaultVoice, getAudioVersion, getChannelCount,
--            getAudioDepthSize, fillSilence, getAcodecVersion,
--            isAcodecAddonInitialized,
--            loadSampleF, saveSampleF, identifySampleF,
--            loadAudioStreamF, playAudioStreamF,
--            lockSampleId, unlockSampleId,
--            createAudioRecorder, destroyAudioRecorder,
--            setSampleInstanceChannelMatrix, setAudioStreamChannelMatrix
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return
  let _ ← Allegro.installAudio
  let _ ← Allegro.initAcodecAddon
  let _ ← Allegro.reserveSamples 4

  IO.println "── Audio Extras Demo ──"

  -- Version info
  let aver ← Allegro.getAudioVersion
  IO.println s!"  getAudioVersion = {aver}"
  let acver ← Allegro.getAcodecVersion
  IO.println s!"  getAcodecVersion = {acver}"
  let acInit ← Allegro.isAcodecAddonInitialized
  IO.println s!"  isAcodecAddonInitialized = {acInit}"

  -- Channel / depth utilities
  let chCnt ← Allegro.getChannelCount 0x10  -- ALLEGRO_CHANNEL_CONF_1
  IO.println s!"  getChannelCount(CONF_1) = {chCnt}"
  let depSz ← Allegro.getAudioDepthSize 0  -- INT8
  IO.println s!"  getAudioDepthSize(INT8) = {depSz}"

  -- fillSilence — takes a raw UInt64 pointer; pass 0 to just test the call path
  -- (null pointer is safe — Allegro checks internally)
  Allegro.fillSilence (0 : UInt64) 0 (0 : UInt32) (0x10 : UInt32)
  IO.println "  fillSilence(null,0) — OK"

  -- createSampleRaw — takes a raw UInt64 pointer, so pass 0 (null) for demo
  -- We can't easily create a valid buffer pointer from Lean, so just test the call
  let rawSpl : Sample ← Allegro.createSampleRaw (0 : UInt64) 256 44100 (0x02 : UInt32) (0x10 : UInt32) (0 : UInt32)
  IO.println s!"  createSampleRaw(null buf) = {rawSpl} (may be 0)"
  if rawSpl != 0 then
    let dataPtr ← rawSpl.sampleData
    IO.println s!"  getSampleData = {dataPtr}"
    rawSpl.destroy

  -- identifySample (with a non-existent file — should return empty)
  let ident ← Allegro.identifySample "/nonexistent.wav"
  IO.println s!"  identifySample(\"/nonexistent.wav\") = \"{ident}\""

  -- Load a real sample (if available)
  let spl : Sample ← Allegro.loadSample "data/beep.wav"
  if spl != 0 then
    -- saveSample
    let saved ← Allegro.saveSample "data/_test_save.wav" spl
    IO.println s!"  saveSample = {saved}"

    -- Create a sample instance and inspect it
    let inst : SampleInstance ← Allegro.createSampleInstance spl
    if inst != 0 then
      let freq ← inst.frequency
      IO.println s!"  getSampleInstanceFrequency = {freq}"
      let att ← inst.isAttached
      IO.println s!"  getSampleInstanceAttached = {att}"
      let ch ← inst.channels
      IO.println s!"  getSampleInstanceChannels = {ch}"
      let dep ← inst.audioDepth
      IO.println s!"  getSampleInstanceDepth = {dep}"
      let tm ← inst.time
      IO.println s!"  getSampleInstanceTime = {tm}"

      -- getSample / setSample
      let sp ← inst.sample
      IO.println s!"  getSample = {sp} (non-zero = original sample)"
      let _ ← inst.setSample spl
      IO.println "  setSample — OK"

      inst.destroy
    spl.destroy
  else
    IO.println "  loadSample(\"data/beep.wav\") failed — skipping instance tests"

  -- Default mixer introspection
  let mixer : Mixer ← Allegro.getDefaultMixer
  if mixer != 0 then
    let mch ← mixer.channels
    IO.println s!"  getMixerChannels = {mch}"
    let mdp ← mixer.audioDepth
    IO.println s!"  getMixerDepth = {mdp}"
    let matt ← mixer.isAttached
    IO.println s!"  getMixerAttached = {matt}"
    let mhas ← mixer.hasAttachments
    IO.println s!"  mixerHasAttachments = {mhas}"

  -- ── Sample ID locking (UNSTABLE) ──
  -- lockSampleId / unlockSampleId — need a valid SampleId from playSampleWithId
  let splLock : Sample ← Allegro.loadSample "data/beep.wav"
  if splLock != 0 then
    let sid ← Allegro.playSampleWithId splLock 1.0 0.0 1.0 (0 : UInt32)
    if sid != 0 then
      let locked ← Allegro.lockSampleId sid
      IO.println s!"  lockSampleId = {locked}"
      Allegro.unlockSampleId sid
      IO.println "  unlockSampleId — OK"
      Allegro.stopSample sid
    else
      IO.println "  playSampleWithId failed — skipping lockSampleId test"
    splLock.destroy
  else
    IO.println "  loadSample for lock test failed — skipping"

  -- setDefaultVoice(0) to clear, then restore
  Allegro.setDefaultVoice (0 : UInt64)
  IO.println "  setDefaultVoice(0) — OK"
  -- Restore default mixer so subsequent playSample calls work
  let _ ← Allegro.restoreDefaultMixer
  let _ ← Allegro.reserveSamples 4

  -- stopSample (with a dummy SAMPLE_ID)
  Allegro.stopSample (0 : UInt64)
  IO.println "  stopSample — OK"

  -- ── Audio stream + voice lifecycle ──
  -- Create a voice: 44100 Hz, INT16, 1-channel (mono)
  let voice : Voice ← Allegro.createVoice 44100 (0x02 : UInt32) (0x10 : UInt32)
  if voice != 0 then
    -- Voice getters
    let vpos ← voice.position
    IO.println s!"  getVoicePosition = {vpos}"
    let vch ← voice.channels
    IO.println s!"  getVoiceChannels = {vch}"
    let vdp ← voice.audioDepth
    IO.println s!"  getVoiceDepth = {vdp}"
    let _ ← voice.setPosition 0
    IO.println "  setVoicePosition(0) — OK"
    let vha ← voice.hasAttachments
    IO.println s!"  voiceHasAttachments = {vha}"

    -- Create a raw audio stream: 4 buffers, 1024 samples, 44100Hz, INT16, mono
    let stream : AudioStream ← Allegro.createAudioStreamRaw 4 1024 44100 (0x02 : UInt32) (0x10 : UInt32)
    if stream != 0 then
      let sFreq ← stream.frequency
      IO.println s!"  getAudioStreamFrequency = {sFreq}"
      let sLen ← stream.streamLength
      IO.println s!"  getAudioStreamLength = {sLen}"
      let sFrags ← stream.fragments
      IO.println s!"  getAudioStreamFragments = {sFrags}"
      let sAvail ← stream.availableFragments
      IO.println s!"  getAvailableAudioStreamFragments = {sAvail}"
      let sCh ← stream.channels
      IO.println s!"  getAudioStreamChannels = {sCh}"
      let sDep ← stream.audioDepth
      IO.println s!"  getAudioStreamDepth = {sDep}"
      let sAtt ← stream.isAttached
      IO.println s!"  getAudioStreamAttached = {sAtt}"
      let sPlayed ← stream.playedSamples
      IO.println s!"  getAudioStreamPlayedSamples = {sPlayed}"

      -- getAudioStreamFragment / setAudioStreamFragment
      let frag ← stream.getFragment
      IO.println s!"  getAudioStreamFragment = {frag}"
      if frag != 0 then
        let _ ← stream.setFragment frag
        IO.println "  setAudioStreamFragment — OK"

      -- Attach stream to voice
      let _ ← stream.attachToVoice voice
      IO.println "  attachAudioStreamToVoice — OK"

      -- setAudioStreamChannelMatrix (1×1 identity — mono → mono)
      let monoMatrix := ByteArray.mk #[0x00, 0x00, 0x80, 0x3F]  -- 1.0f in IEEE 754 LE
      let _ ← stream.setChannelMatrix monoMatrix
      IO.println "  setAudioStreamChannelMatrix — OK"

      stream.destroy
      IO.println "  destroyAudioStream — OK"
    else
      IO.println "  createAudioStreamRaw returned null — skipping stream tests"

    -- Sample instance attached to voice
    let spl2 : Sample ← Allegro.loadSample "data/beep.wav"
    if spl2 != 0 then
      let inst2 : SampleInstance ← Allegro.createSampleInstance spl2
      if inst2 != 0 then
        -- setSampleInstanceLength
        let _ ← inst2.setLength 512
        IO.println "  setSampleInstanceLength(512) — OK"

        -- attachSampleInstanceToVoice
        let _ ← inst2.attachToVoice voice
        IO.println "  attachSampleInstanceToVoice — OK"

        -- setSampleInstanceChannelMatrix
        let monoMatrix2 := ByteArray.mk #[0x00, 0x00, 0x80, 0x3F]
        let _ ← inst2.setChannelMatrix monoMatrix2
        IO.println "  setSampleInstanceChannelMatrix — OK"

        inst2.destroy
      spl2.destroy
    else
      IO.println "  loadSample(beep.wav) failed — skipping instance→voice tests"

    voice.destroy
    IO.println "  destroyVoice — OK"
  else
    IO.println "  createVoice returned null — skipping voice/stream tests"

  -- ── Audio file (ALLEGRO_FILE) operations ──
  let file ← Allegro.fopen "data/beep.wav" "rb"
  if file != 0 then
    -- loadSampleF
    let fSpl ← Allegro.loadSampleF file ".wav"
    IO.println s!"  loadSampleF = {fSpl}"
    if fSpl != 0 then
      -- saveSampleF
      let wf ← Allegro.fopen "data/_test_save_f.wav" "wb"
      if wf != 0 then
        let _ ← Allegro.saveSampleF wf ".wav" fSpl
        IO.println "  saveSampleF — OK"
      -- identifySampleF — reopen the saved file
      let rf ← Allegro.fopen "data/_test_save_f.wav" "rb"
      if rf != 0 then
        let idnt ← Allegro.identifySampleF rf
        IO.println s!"  identifySampleF = \"{idnt}\""
      Allegro.destroySample fSpl
    -- loadAudioStreamF
    let f2 ← Allegro.fopen "data/beep.wav" "rb"
    if f2 != 0 then
      let fStream : AudioStream ← Allegro.loadAudioStreamF f2 ".wav" 4 1024
      IO.println s!"  loadAudioStreamF = {fStream}"
      if fStream != 0 then
        fStream.destroy
    -- playAudioStreamF — use null to avoid double-free bug (see TODO.md)
    let fPlay ← Allegro.playAudioStreamF (0 : UInt64) ".wav"
    IO.println s!"  playAudioStreamF(null) = {fPlay} (expected 0)"
  else
    IO.println "  fopen(data/beep.wav) failed — skipping audio file tests"

  -- ── Audio recorder (UNSTABLE) ──
  -- createAudioRecorder: fragCount=5, samples=1024, freq=44100, depth=INT16, chanConf=1
  let rec : AudioRecorder ← Allegro.createAudioRecorder 5 1024 44100 (0x02 : UInt32) (0x10 : UInt32)
  if rec != 0 then
    let _ ← rec.start
    IO.println "  startAudioRecorder — OK"
    let isRec ← rec.isRecording
    IO.println s!"  isAudioRecorderRecording = {isRec}"
    let recSrc ← rec.eventSource
    IO.println s!"  getAudioRecorderEventSource = {recSrc}"
    rec.stop
    IO.println "  stopAudioRecorder — OK"
    rec.destroy
    IO.println "  destroyAudioRecorder — OK"
  else
    IO.println "  createAudioRecorder returned null (no recording device?) — skipping"

  Allegro.uninstallAudio
  Allegro.uninstallSystem
  IO.println "── done ──"
