// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

/// Account
class NativeLibrary {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NativeLibrary(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NativeLibrary.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  int __ctype_get_mb_cur_max() {
    return ___ctype_get_mb_cur_max();
  }

  late final ___ctype_get_mb_cur_maxPtr =
      _lookup<ffi.NativeFunction<ffi.Size Function()>>(
          '__ctype_get_mb_cur_max');
  late final ___ctype_get_mb_cur_max =
      ___ctype_get_mb_cur_maxPtr.asFunction<int Function()>();

  double atof(
    ffi.Pointer<ffi.Char> __nptr,
  ) {
    return _atof(
      __nptr,
    );
  }

  late final _atofPtr =
      _lookup<ffi.NativeFunction<ffi.Double Function(ffi.Pointer<ffi.Char>)>>(
          'atof');
  late final _atof =
      _atofPtr.asFunction<double Function(ffi.Pointer<ffi.Char>)>();

  int atoi(
    ffi.Pointer<ffi.Char> __nptr,
  ) {
    return _atoi(
      __nptr,
    );
  }

  late final _atoiPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>)>>(
          'atoi');
  late final _atoi = _atoiPtr.asFunction<int Function(ffi.Pointer<ffi.Char>)>();

  int atol(
    ffi.Pointer<ffi.Char> __nptr,
  ) {
    return _atol(
      __nptr,
    );
  }

  late final _atolPtr =
      _lookup<ffi.NativeFunction<ffi.Long Function(ffi.Pointer<ffi.Char>)>>(
          'atol');
  late final _atol = _atolPtr.asFunction<int Function(ffi.Pointer<ffi.Char>)>();

  int atoll(
    ffi.Pointer<ffi.Char> __nptr,
  ) {
    return _atoll(
      __nptr,
    );
  }

  late final _atollPtr =
      _lookup<ffi.NativeFunction<ffi.LongLong Function(ffi.Pointer<ffi.Char>)>>(
          'atoll');
  late final _atoll =
      _atollPtr.asFunction<int Function(ffi.Pointer<ffi.Char>)>();

  double strtod(
    ffi.Pointer<ffi.Char> __nptr,
    ffi.Pointer<ffi.Pointer<ffi.Char>> __endptr,
  ) {
    return _strtod(
      __nptr,
      __endptr,
    );
  }

  late final _strtodPtr = _lookup<
      ffi.NativeFunction<
          ffi.Double Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Pointer<ffi.Char>>)>>('strtod');
  late final _strtod = _strtodPtr.asFunction<
      double Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Pointer<ffi.Char>>)>();

  double strtof(
    ffi.Pointer<ffi.Char> __nptr,
    ffi.Pointer<ffi.Pointer<ffi.Char>> __endptr,
  ) {
    return _strtof(
      __nptr,
      __endptr,
    );
  }

  late final _strtofPtr = _lookup<
      ffi.NativeFunction<
          ffi.Float Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Pointer<ffi.Char>>)>>('strtof');
  late final _strtof = _strtofPtr.asFunction<
      double Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Pointer<ffi.Char>>)>();

  int strtol(
    ffi.Pointer<ffi.Char> __nptr,
    ffi.Pointer<ffi.Pointer<ffi.Char>> __endptr,
    int __base,
  ) {
    return _strtol(
      __nptr,
      __endptr,
      __base,
    );
  }

  late final _strtolPtr = _lookup<
      ffi.NativeFunction<
          ffi.Long Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Pointer<ffi.Char>>, ffi.Int)>>('strtol');
  late final _strtol = _strtolPtr.asFunction<
      int Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Pointer<ffi.Char>>, int)>();

  int strtoul(
    ffi.Pointer<ffi.Char> __nptr,
    ffi.Pointer<ffi.Pointer<ffi.Char>> __endptr,
    int __base,
  ) {
    return _strtoul(
      __nptr,
      __endptr,
      __base,
    );
  }

  late final _strtoulPtr = _lookup<
      ffi.NativeFunction<
          ffi.UnsignedLong Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Pointer<ffi.Char>>, ffi.Int)>>('strtoul');
  late final _strtoul = _strtoulPtr.asFunction<
      int Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Pointer<ffi.Char>>, int)>();

  int strtoq(
    ffi.Pointer<ffi.Char> __nptr,
    ffi.Pointer<ffi.Pointer<ffi.Char>> __endptr,
    int __base,
  ) {
    return _strtoq(
      __nptr,
      __endptr,
      __base,
    );
  }

  late final _strtoqPtr = _lookup<
      ffi.NativeFunction<
          ffi.LongLong Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Pointer<ffi.Char>>, ffi.Int)>>('strtoq');
  late final _strtoq = _strtoqPtr.asFunction<
      int Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Pointer<ffi.Char>>, int)>();

  int strtouq(
    ffi.Pointer<ffi.Char> __nptr,
    ffi.Pointer<ffi.Pointer<ffi.Char>> __endptr,
    int __base,
  ) {
    return _strtouq(
      __nptr,
      __endptr,
      __base,
    );
  }

  late final _strtouqPtr = _lookup<
      ffi.NativeFunction<
          ffi.UnsignedLongLong Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Pointer<ffi.Char>>, ffi.Int)>>('strtouq');
  late final _strtouq = _strtouqPtr.asFunction<
      int Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Pointer<ffi.Char>>, int)>();

  int strtoll(
    ffi.Pointer<ffi.Char> __nptr,
    ffi.Pointer<ffi.Pointer<ffi.Char>> __endptr,
    int __base,
  ) {
    return _strtoll(
      __nptr,
      __endptr,
      __base,
    );
  }

  late final _strtollPtr = _lookup<
      ffi.NativeFunction<
          ffi.LongLong Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Pointer<ffi.Char>>, ffi.Int)>>('strtoll');
  late final _strtoll = _strtollPtr.asFunction<
      int Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Pointer<ffi.Char>>, int)>();

  int strtoull(
    ffi.Pointer<ffi.Char> __nptr,
    ffi.Pointer<ffi.Pointer<ffi.Char>> __endptr,
    int __base,
  ) {
    return _strtoull(
      __nptr,
      __endptr,
      __base,
    );
  }

  late final _strtoullPtr = _lookup<
      ffi.NativeFunction<
          ffi.UnsignedLongLong Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Pointer<ffi.Char>>, ffi.Int)>>('strtoull');
  late final _strtoull = _strtoullPtr.asFunction<
      int Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Pointer<ffi.Char>>, int)>();

  ffi.Pointer<ffi.Char> l64a(
    int __n,
  ) {
    return _l64a(
      __n,
    );
  }

  late final _l64aPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Long)>>(
          'l64a');
  late final _l64a = _l64aPtr.asFunction<ffi.Pointer<ffi.Char> Function(int)>();

  int a64l(
    ffi.Pointer<ffi.Char> __s,
  ) {
    return _a64l(
      __s,
    );
  }

  late final _a64lPtr =
      _lookup<ffi.NativeFunction<ffi.Long Function(ffi.Pointer<ffi.Char>)>>(
          'a64l');
  late final _a64l = _a64lPtr.asFunction<int Function(ffi.Pointer<ffi.Char>)>();

  int select(
    int __nfds,
    ffi.Pointer<fd_set> __readfds,
    ffi.Pointer<fd_set> __writefds,
    ffi.Pointer<fd_set> __exceptfds,
    ffi.Pointer<timeval> __timeout,
  ) {
    return _select(
      __nfds,
      __readfds,
      __writefds,
      __exceptfds,
      __timeout,
    );
  }

  late final _selectPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Int, ffi.Pointer<fd_set>, ffi.Pointer<fd_set>,
              ffi.Pointer<fd_set>, ffi.Pointer<timeval>)>>('select');
  late final _select = _selectPtr.asFunction<
      int Function(int, ffi.Pointer<fd_set>, ffi.Pointer<fd_set>,
          ffi.Pointer<fd_set>, ffi.Pointer<timeval>)>();

  int pselect(
    int __nfds,
    ffi.Pointer<fd_set> __readfds,
    ffi.Pointer<fd_set> __writefds,
    ffi.Pointer<fd_set> __exceptfds,
    ffi.Pointer<timespec> __timeout,
    ffi.Pointer<__sigset_t> __sigmask,
  ) {
    return _pselect(
      __nfds,
      __readfds,
      __writefds,
      __exceptfds,
      __timeout,
      __sigmask,
    );
  }

  late final _pselectPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Int,
              ffi.Pointer<fd_set>,
              ffi.Pointer<fd_set>,
              ffi.Pointer<fd_set>,
              ffi.Pointer<timespec>,
              ffi.Pointer<__sigset_t>)>>('pselect');
  late final _pselect = _pselectPtr.asFunction<
      int Function(
          int,
          ffi.Pointer<fd_set>,
          ffi.Pointer<fd_set>,
          ffi.Pointer<fd_set>,
          ffi.Pointer<timespec>,
          ffi.Pointer<__sigset_t>)>();

  int random() {
    return _random();
  }

  late final _randomPtr =
      _lookup<ffi.NativeFunction<ffi.Long Function()>>('random');
  late final _random = _randomPtr.asFunction<int Function()>();

  void srandom(
    int __seed,
  ) {
    return _srandom(
      __seed,
    );
  }

  late final _srandomPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.UnsignedInt)>>(
          'srandom');
  late final _srandom = _srandomPtr.asFunction<void Function(int)>();

  ffi.Pointer<ffi.Char> initstate(
    int __seed,
    ffi.Pointer<ffi.Char> __statebuf,
    int __statelen,
  ) {
    return _initstate(
      __seed,
      __statebuf,
      __statelen,
    );
  }

  late final _initstatePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.UnsignedInt, ffi.Pointer<ffi.Char>, ffi.Size)>>('initstate');
  late final _initstate = _initstatePtr.asFunction<
      ffi.Pointer<ffi.Char> Function(int, ffi.Pointer<ffi.Char>, int)>();

  ffi.Pointer<ffi.Char> setstate(
    ffi.Pointer<ffi.Char> __statebuf,
  ) {
    return _setstate(
      __statebuf,
    );
  }

  late final _setstatePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>>('setstate');
  late final _setstate = _setstatePtr
      .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();

  int random_r(
    ffi.Pointer<random_data> __buf,
    ffi.Pointer<ffi.Int32> __result,
  ) {
    return _random_r(
      __buf,
      __result,
    );
  }

  late final _random_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<random_data>, ffi.Pointer<ffi.Int32>)>>('random_r');
  late final _random_r = _random_rPtr.asFunction<
      int Function(ffi.Pointer<random_data>, ffi.Pointer<ffi.Int32>)>();

  int srandom_r(
    int __seed,
    ffi.Pointer<random_data> __buf,
  ) {
    return _srandom_r(
      __seed,
      __buf,
    );
  }

  late final _srandom_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.UnsignedInt, ffi.Pointer<random_data>)>>('srandom_r');
  late final _srandom_r =
      _srandom_rPtr.asFunction<int Function(int, ffi.Pointer<random_data>)>();

  int initstate_r(
    int __seed,
    ffi.Pointer<ffi.Char> __statebuf,
    int __statelen,
    ffi.Pointer<random_data> __buf,
  ) {
    return _initstate_r(
      __seed,
      __statebuf,
      __statelen,
      __buf,
    );
  }

  late final _initstate_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.UnsignedInt, ffi.Pointer<ffi.Char>, ffi.Size,
              ffi.Pointer<random_data>)>>('initstate_r');
  late final _initstate_r = _initstate_rPtr.asFunction<
      int Function(
          int, ffi.Pointer<ffi.Char>, int, ffi.Pointer<random_data>)>();

  int setstate_r(
    ffi.Pointer<ffi.Char> __statebuf,
    ffi.Pointer<random_data> __buf,
  ) {
    return _setstate_r(
      __statebuf,
      __buf,
    );
  }

  late final _setstate_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<ffi.Char>, ffi.Pointer<random_data>)>>('setstate_r');
  late final _setstate_r = _setstate_rPtr.asFunction<
      int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<random_data>)>();

  int rand() {
    return _rand();
  }

  late final _randPtr = _lookup<ffi.NativeFunction<ffi.Int Function()>>('rand');
  late final _rand = _randPtr.asFunction<int Function()>();

  void srand(
    int __seed,
  ) {
    return _srand(
      __seed,
    );
  }

  late final _srandPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.UnsignedInt)>>('srand');
  late final _srand = _srandPtr.asFunction<void Function(int)>();

  int rand_r(
    ffi.Pointer<ffi.UnsignedInt> __seed,
  ) {
    return _rand_r(
      __seed,
    );
  }

  late final _rand_rPtr = _lookup<
          ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.UnsignedInt>)>>(
      'rand_r');
  late final _rand_r =
      _rand_rPtr.asFunction<int Function(ffi.Pointer<ffi.UnsignedInt>)>();

  double drand48() {
    return _drand48();
  }

  late final _drand48Ptr =
      _lookup<ffi.NativeFunction<ffi.Double Function()>>('drand48');
  late final _drand48 = _drand48Ptr.asFunction<double Function()>();

  double erand48(
    ffi.Pointer<ffi.UnsignedShort> __xsubi,
  ) {
    return _erand48(
      __xsubi,
    );
  }

  late final _erand48Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Double Function(ffi.Pointer<ffi.UnsignedShort>)>>('erand48');
  late final _erand48 =
      _erand48Ptr.asFunction<double Function(ffi.Pointer<ffi.UnsignedShort>)>();

  int lrand48() {
    return _lrand48();
  }

  late final _lrand48Ptr =
      _lookup<ffi.NativeFunction<ffi.Long Function()>>('lrand48');
  late final _lrand48 = _lrand48Ptr.asFunction<int Function()>();

  int nrand48(
    ffi.Pointer<ffi.UnsignedShort> __xsubi,
  ) {
    return _nrand48(
      __xsubi,
    );
  }

  late final _nrand48Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Long Function(ffi.Pointer<ffi.UnsignedShort>)>>('nrand48');
  late final _nrand48 =
      _nrand48Ptr.asFunction<int Function(ffi.Pointer<ffi.UnsignedShort>)>();

  int mrand48() {
    return _mrand48();
  }

  late final _mrand48Ptr =
      _lookup<ffi.NativeFunction<ffi.Long Function()>>('mrand48');
  late final _mrand48 = _mrand48Ptr.asFunction<int Function()>();

  int jrand48(
    ffi.Pointer<ffi.UnsignedShort> __xsubi,
  ) {
    return _jrand48(
      __xsubi,
    );
  }

  late final _jrand48Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Long Function(ffi.Pointer<ffi.UnsignedShort>)>>('jrand48');
  late final _jrand48 =
      _jrand48Ptr.asFunction<int Function(ffi.Pointer<ffi.UnsignedShort>)>();

  void srand48(
    int __seedval,
  ) {
    return _srand48(
      __seedval,
    );
  }

  late final _srand48Ptr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Long)>>('srand48');
  late final _srand48 = _srand48Ptr.asFunction<void Function(int)>();

  ffi.Pointer<ffi.UnsignedShort> seed48(
    ffi.Pointer<ffi.UnsignedShort> __seed16v,
  ) {
    return _seed48(
      __seed16v,
    );
  }

  late final _seed48Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.UnsignedShort> Function(
              ffi.Pointer<ffi.UnsignedShort>)>>('seed48');
  late final _seed48 = _seed48Ptr.asFunction<
      ffi.Pointer<ffi.UnsignedShort> Function(
          ffi.Pointer<ffi.UnsignedShort>)>();

  void lcong48(
    ffi.Pointer<ffi.UnsignedShort> __param,
  ) {
    return _lcong48(
      __param,
    );
  }

  late final _lcong48Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<ffi.UnsignedShort>)>>('lcong48');
  late final _lcong48 =
      _lcong48Ptr.asFunction<void Function(ffi.Pointer<ffi.UnsignedShort>)>();

  int drand48_r(
    ffi.Pointer<drand48_data> __buffer,
    ffi.Pointer<ffi.Double> __result,
  ) {
    return _drand48_r(
      __buffer,
      __result,
    );
  }

  late final _drand48_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<drand48_data>,
              ffi.Pointer<ffi.Double>)>>('drand48_r');
  late final _drand48_r = _drand48_rPtr.asFunction<
      int Function(ffi.Pointer<drand48_data>, ffi.Pointer<ffi.Double>)>();

  int erand48_r(
    ffi.Pointer<ffi.UnsignedShort> __xsubi,
    ffi.Pointer<drand48_data> __buffer,
    ffi.Pointer<ffi.Double> __result,
  ) {
    return _erand48_r(
      __xsubi,
      __buffer,
      __result,
    );
  }

  late final _erand48_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<ffi.UnsignedShort>,
              ffi.Pointer<drand48_data>,
              ffi.Pointer<ffi.Double>)>>('erand48_r');
  late final _erand48_r = _erand48_rPtr.asFunction<
      int Function(ffi.Pointer<ffi.UnsignedShort>, ffi.Pointer<drand48_data>,
          ffi.Pointer<ffi.Double>)>();

  int lrand48_r(
    ffi.Pointer<drand48_data> __buffer,
    ffi.Pointer<ffi.Long> __result,
  ) {
    return _lrand48_r(
      __buffer,
      __result,
    );
  }

  late final _lrand48_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<drand48_data>, ffi.Pointer<ffi.Long>)>>('lrand48_r');
  late final _lrand48_r = _lrand48_rPtr.asFunction<
      int Function(ffi.Pointer<drand48_data>, ffi.Pointer<ffi.Long>)>();

  int nrand48_r(
    ffi.Pointer<ffi.UnsignedShort> __xsubi,
    ffi.Pointer<drand48_data> __buffer,
    ffi.Pointer<ffi.Long> __result,
  ) {
    return _nrand48_r(
      __xsubi,
      __buffer,
      __result,
    );
  }

  late final _nrand48_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.UnsignedShort>,
              ffi.Pointer<drand48_data>, ffi.Pointer<ffi.Long>)>>('nrand48_r');
  late final _nrand48_r = _nrand48_rPtr.asFunction<
      int Function(ffi.Pointer<ffi.UnsignedShort>, ffi.Pointer<drand48_data>,
          ffi.Pointer<ffi.Long>)>();

  int mrand48_r(
    ffi.Pointer<drand48_data> __buffer,
    ffi.Pointer<ffi.Long> __result,
  ) {
    return _mrand48_r(
      __buffer,
      __result,
    );
  }

  late final _mrand48_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<drand48_data>, ffi.Pointer<ffi.Long>)>>('mrand48_r');
  late final _mrand48_r = _mrand48_rPtr.asFunction<
      int Function(ffi.Pointer<drand48_data>, ffi.Pointer<ffi.Long>)>();

  int jrand48_r(
    ffi.Pointer<ffi.UnsignedShort> __xsubi,
    ffi.Pointer<drand48_data> __buffer,
    ffi.Pointer<ffi.Long> __result,
  ) {
    return _jrand48_r(
      __xsubi,
      __buffer,
      __result,
    );
  }

  late final _jrand48_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.UnsignedShort>,
              ffi.Pointer<drand48_data>, ffi.Pointer<ffi.Long>)>>('jrand48_r');
  late final _jrand48_r = _jrand48_rPtr.asFunction<
      int Function(ffi.Pointer<ffi.UnsignedShort>, ffi.Pointer<drand48_data>,
          ffi.Pointer<ffi.Long>)>();

  int srand48_r(
    int __seedval,
    ffi.Pointer<drand48_data> __buffer,
  ) {
    return _srand48_r(
      __seedval,
      __buffer,
    );
  }

  late final _srand48_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Long, ffi.Pointer<drand48_data>)>>('srand48_r');
  late final _srand48_r =
      _srand48_rPtr.asFunction<int Function(int, ffi.Pointer<drand48_data>)>();

  int seed48_r(
    ffi.Pointer<ffi.UnsignedShort> __seed16v,
    ffi.Pointer<drand48_data> __buffer,
  ) {
    return _seed48_r(
      __seed16v,
      __buffer,
    );
  }

  late final _seed48_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.UnsignedShort>,
              ffi.Pointer<drand48_data>)>>('seed48_r');
  late final _seed48_r = _seed48_rPtr.asFunction<
      int Function(
          ffi.Pointer<ffi.UnsignedShort>, ffi.Pointer<drand48_data>)>();

  int lcong48_r(
    ffi.Pointer<ffi.UnsignedShort> __param,
    ffi.Pointer<drand48_data> __buffer,
  ) {
    return _lcong48_r(
      __param,
      __buffer,
    );
  }

  late final _lcong48_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.UnsignedShort>,
              ffi.Pointer<drand48_data>)>>('lcong48_r');
  late final _lcong48_r = _lcong48_rPtr.asFunction<
      int Function(
          ffi.Pointer<ffi.UnsignedShort>, ffi.Pointer<drand48_data>)>();

  ffi.Pointer<ffi.Void> malloc(
    int __size,
  ) {
    return _malloc(
      __size,
    );
  }

  late final _mallocPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Void> Function(ffi.Size)>>(
          'malloc');
  late final _malloc =
      _mallocPtr.asFunction<ffi.Pointer<ffi.Void> Function(int)>();

  ffi.Pointer<ffi.Void> calloc(
    int __nmemb,
    int __size,
  ) {
    return _calloc(
      __nmemb,
      __size,
    );
  }

  late final _callocPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Void> Function(ffi.Size, ffi.Size)>>('calloc');
  late final _calloc =
      _callocPtr.asFunction<ffi.Pointer<ffi.Void> Function(int, int)>();

  ffi.Pointer<ffi.Void> realloc(
    ffi.Pointer<ffi.Void> __ptr,
    int __size,
  ) {
    return _realloc(
      __ptr,
      __size,
    );
  }

  late final _reallocPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Void> Function(
              ffi.Pointer<ffi.Void>, ffi.Size)>>('realloc');
  late final _realloc = _reallocPtr
      .asFunction<ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Void>, int)>();

  void free(
    ffi.Pointer<ffi.Void> __ptr,
  ) {
    return _free(
      __ptr,
    );
  }

  late final _freePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>(
          'free');
  late final _free =
      _freePtr.asFunction<void Function(ffi.Pointer<ffi.Void>)>();

  ffi.Pointer<ffi.Void> reallocarray(
    ffi.Pointer<ffi.Void> __ptr,
    int __nmemb,
    int __size,
  ) {
    return _reallocarray(
      __ptr,
      __nmemb,
      __size,
    );
  }

  late final _reallocarrayPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Void> Function(
              ffi.Pointer<ffi.Void>, ffi.Size, ffi.Size)>>('reallocarray');
  late final _reallocarray = _reallocarrayPtr.asFunction<
      ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Void>, int, int)>();

  ffi.Pointer<ffi.Void> alloca(
    int __size,
  ) {
    return _alloca(
      __size,
    );
  }

  late final _allocaPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Void> Function(ffi.Size)>>(
          'alloca');
  late final _alloca =
      _allocaPtr.asFunction<ffi.Pointer<ffi.Void> Function(int)>();

  ffi.Pointer<ffi.Void> valloc(
    int __size,
  ) {
    return _valloc(
      __size,
    );
  }

  late final _vallocPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Void> Function(ffi.Size)>>(
          'valloc');
  late final _valloc =
      _vallocPtr.asFunction<ffi.Pointer<ffi.Void> Function(int)>();

  int posix_memalign(
    ffi.Pointer<ffi.Pointer<ffi.Void>> __memptr,
    int __alignment,
    int __size,
  ) {
    return _posix_memalign(
      __memptr,
      __alignment,
      __size,
    );
  }

  late final _posix_memalignPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.Pointer<ffi.Void>>, ffi.Size,
              ffi.Size)>>('posix_memalign');
  late final _posix_memalign = _posix_memalignPtr
      .asFunction<int Function(ffi.Pointer<ffi.Pointer<ffi.Void>>, int, int)>();

  ffi.Pointer<ffi.Void> aligned_alloc(
    int __alignment,
    int __size,
  ) {
    return _aligned_alloc(
      __alignment,
      __size,
    );
  }

  late final _aligned_allocPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Void> Function(ffi.Size, ffi.Size)>>('aligned_alloc');
  late final _aligned_alloc =
      _aligned_allocPtr.asFunction<ffi.Pointer<ffi.Void> Function(int, int)>();

  void abort() {
    return _abort();
  }

  late final _abortPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>('abort');
  late final _abort = _abortPtr.asFunction<void Function()>();

  int atexit(
    ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>> __func,
  ) {
    return _atexit(
      __func,
    );
  }

  late final _atexitPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>>)>>('atexit');
  late final _atexit = _atexitPtr.asFunction<
      int Function(ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>>)>();

  int at_quick_exit(
    ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>> __func,
  ) {
    return _at_quick_exit(
      __func,
    );
  }

  late final _at_quick_exitPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(
                  ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>>)>>(
      'at_quick_exit');
  late final _at_quick_exit = _at_quick_exitPtr.asFunction<
      int Function(ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>>)>();

  int on_exit(
    ffi.Pointer<
            ffi.NativeFunction<
                ffi.Void Function(
                    ffi.Int __status, ffi.Pointer<ffi.Void> __arg)>>
        __func,
    ffi.Pointer<ffi.Void> __arg,
  ) {
    return _on_exit(
      __func,
      __arg,
    );
  }

  late final _on_exitPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<
                  ffi.NativeFunction<
                      ffi.Void Function(
                          ffi.Int __status, ffi.Pointer<ffi.Void> __arg)>>,
              ffi.Pointer<ffi.Void>)>>('on_exit');
  late final _on_exit = _on_exitPtr.asFunction<
      int Function(
          ffi.Pointer<
              ffi.NativeFunction<
                  ffi.Void Function(
                      ffi.Int __status, ffi.Pointer<ffi.Void> __arg)>>,
          ffi.Pointer<ffi.Void>)>();

  void exit(
    int __status,
  ) {
    return _exit(
      __status,
    );
  }

  late final _exitPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int)>>('exit');
  late final _exit = _exitPtr.asFunction<void Function(int)>();

  void quick_exit(
    int __status,
  ) {
    return _quick_exit(
      __status,
    );
  }

  late final _quick_exitPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int)>>('quick_exit');
  late final _quick_exit = _quick_exitPtr.asFunction<void Function(int)>();

  void _Exit(
    int __status,
  ) {
    return __Exit(
      __status,
    );
  }

  late final __ExitPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int)>>('_Exit');
  late final __Exit = __ExitPtr.asFunction<void Function(int)>();

  ffi.Pointer<ffi.Char> getenv(
    ffi.Pointer<ffi.Char> __name,
  ) {
    return _getenv(
      __name,
    );
  }

  late final _getenvPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>>('getenv');
  late final _getenv = _getenvPtr
      .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();

  int putenv(
    ffi.Pointer<ffi.Char> __string,
  ) {
    return _putenv(
      __string,
    );
  }

  late final _putenvPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>)>>(
          'putenv');
  late final _putenv =
      _putenvPtr.asFunction<int Function(ffi.Pointer<ffi.Char>)>();

  int setenv(
    ffi.Pointer<ffi.Char> __name,
    ffi.Pointer<ffi.Char> __value,
    int __replace,
  ) {
    return _setenv(
      __name,
      __value,
      __replace,
    );
  }

  late final _setenvPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>,
              ffi.Int)>>('setenv');
  late final _setenv = _setenvPtr.asFunction<
      int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();

  int unsetenv(
    ffi.Pointer<ffi.Char> __name,
  ) {
    return _unsetenv(
      __name,
    );
  }

  late final _unsetenvPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>)>>(
          'unsetenv');
  late final _unsetenv =
      _unsetenvPtr.asFunction<int Function(ffi.Pointer<ffi.Char>)>();

  int clearenv() {
    return _clearenv();
  }

  late final _clearenvPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function()>>('clearenv');
  late final _clearenv = _clearenvPtr.asFunction<int Function()>();

  ffi.Pointer<ffi.Char> mktemp(
    ffi.Pointer<ffi.Char> __template,
  ) {
    return _mktemp(
      __template,
    );
  }

  late final _mktempPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>>('mktemp');
  late final _mktemp = _mktempPtr
      .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();

  int mkstemp(
    ffi.Pointer<ffi.Char> __template,
  ) {
    return _mkstemp(
      __template,
    );
  }

  late final _mkstempPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>)>>(
          'mkstemp');
  late final _mkstemp =
      _mkstempPtr.asFunction<int Function(ffi.Pointer<ffi.Char>)>();

  int mkstemps(
    ffi.Pointer<ffi.Char> __template,
    int __suffixlen,
  ) {
    return _mkstemps(
      __template,
      __suffixlen,
    );
  }

  late final _mkstempsPtr = _lookup<
          ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Int)>>(
      'mkstemps');
  late final _mkstemps =
      _mkstempsPtr.asFunction<int Function(ffi.Pointer<ffi.Char>, int)>();

  ffi.Pointer<ffi.Char> mkdtemp(
    ffi.Pointer<ffi.Char> __template,
  ) {
    return _mkdtemp(
      __template,
    );
  }

  late final _mkdtempPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>>('mkdtemp');
  late final _mkdtemp = _mkdtempPtr
      .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();

  int system(
    ffi.Pointer<ffi.Char> __command,
  ) {
    return _system(
      __command,
    );
  }

  late final _systemPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>)>>(
          'system');
  late final _system =
      _systemPtr.asFunction<int Function(ffi.Pointer<ffi.Char>)>();

  ffi.Pointer<ffi.Char> realpath(
    ffi.Pointer<ffi.Char> __name,
    ffi.Pointer<ffi.Char> __resolved,
  ) {
    return _realpath(
      __name,
      __resolved,
    );
  }

  late final _realpathPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>>('realpath');
  late final _realpath = _realpathPtr.asFunction<
      ffi.Pointer<ffi.Char> Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>();

  ffi.Pointer<ffi.Void> bsearch(
    ffi.Pointer<ffi.Void> __key,
    ffi.Pointer<ffi.Void> __base,
    int __nmemb,
    int __size,
    __compar_fn_t __compar,
  ) {
    return _bsearch(
      __key,
      __base,
      __nmemb,
      __size,
      __compar,
    );
  }

  late final _bsearchPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Void> Function(
              ffi.Pointer<ffi.Void>,
              ffi.Pointer<ffi.Void>,
              ffi.Size,
              ffi.Size,
              __compar_fn_t)>>('bsearch');
  late final _bsearch = _bsearchPtr.asFunction<
      ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Void>,
          ffi.Pointer<ffi.Void>, int, int, __compar_fn_t)>();

  void qsort(
    ffi.Pointer<ffi.Void> __base,
    int __nmemb,
    int __size,
    __compar_fn_t __compar,
  ) {
    return _qsort(
      __base,
      __nmemb,
      __size,
      __compar,
    );
  }

  late final _qsortPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Size, ffi.Size,
              __compar_fn_t)>>('qsort');
  late final _qsort = _qsortPtr.asFunction<
      void Function(ffi.Pointer<ffi.Void>, int, int, __compar_fn_t)>();

  int abs(
    int __x,
  ) {
    return _abs(
      __x,
    );
  }

  late final _absPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int)>>('abs');
  late final _abs = _absPtr.asFunction<int Function(int)>();

  int labs(
    int __x,
  ) {
    return _labs(
      __x,
    );
  }

  late final _labsPtr =
      _lookup<ffi.NativeFunction<ffi.Long Function(ffi.Long)>>('labs');
  late final _labs = _labsPtr.asFunction<int Function(int)>();

  int llabs(
    int __x,
  ) {
    return _llabs(
      __x,
    );
  }

  late final _llabsPtr =
      _lookup<ffi.NativeFunction<ffi.LongLong Function(ffi.LongLong)>>('llabs');
  late final _llabs = _llabsPtr.asFunction<int Function(int)>();

  div_t div(
    int __numer,
    int __denom,
  ) {
    return _div(
      __numer,
      __denom,
    );
  }

  late final _divPtr =
      _lookup<ffi.NativeFunction<div_t Function(ffi.Int, ffi.Int)>>('div');
  late final _div = _divPtr.asFunction<div_t Function(int, int)>();

  ldiv_t ldiv(
    int __numer,
    int __denom,
  ) {
    return _ldiv(
      __numer,
      __denom,
    );
  }

  late final _ldivPtr =
      _lookup<ffi.NativeFunction<ldiv_t Function(ffi.Long, ffi.Long)>>('ldiv');
  late final _ldiv = _ldivPtr.asFunction<ldiv_t Function(int, int)>();

  lldiv_t lldiv(
    int __numer,
    int __denom,
  ) {
    return _lldiv(
      __numer,
      __denom,
    );
  }

  late final _lldivPtr =
      _lookup<ffi.NativeFunction<lldiv_t Function(ffi.LongLong, ffi.LongLong)>>(
          'lldiv');
  late final _lldiv = _lldivPtr.asFunction<lldiv_t Function(int, int)>();

  ffi.Pointer<ffi.Char> ecvt(
    double __value,
    int __ndigit,
    ffi.Pointer<ffi.Int> __decpt,
    ffi.Pointer<ffi.Int> __sign,
  ) {
    return _ecvt(
      __value,
      __ndigit,
      __decpt,
      __sign,
    );
  }

  late final _ecvtPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(ffi.Double, ffi.Int,
              ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>)>>('ecvt');
  late final _ecvt = _ecvtPtr.asFunction<
      ffi.Pointer<ffi.Char> Function(
          double, int, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>)>();

  ffi.Pointer<ffi.Char> fcvt(
    double __value,
    int __ndigit,
    ffi.Pointer<ffi.Int> __decpt,
    ffi.Pointer<ffi.Int> __sign,
  ) {
    return _fcvt(
      __value,
      __ndigit,
      __decpt,
      __sign,
    );
  }

  late final _fcvtPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(ffi.Double, ffi.Int,
              ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>)>>('fcvt');
  late final _fcvt = _fcvtPtr.asFunction<
      ffi.Pointer<ffi.Char> Function(
          double, int, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>)>();

  ffi.Pointer<ffi.Char> gcvt(
    double __value,
    int __ndigit,
    ffi.Pointer<ffi.Char> __buf,
  ) {
    return _gcvt(
      __value,
      __ndigit,
      __buf,
    );
  }

  late final _gcvtPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Double, ffi.Int, ffi.Pointer<ffi.Char>)>>('gcvt');
  late final _gcvt = _gcvtPtr.asFunction<
      ffi.Pointer<ffi.Char> Function(double, int, ffi.Pointer<ffi.Char>)>();

  int ecvt_r(
    double __value,
    int __ndigit,
    ffi.Pointer<ffi.Int> __decpt,
    ffi.Pointer<ffi.Int> __sign,
    ffi.Pointer<ffi.Char> __buf,
    int __len,
  ) {
    return _ecvt_r(
      __value,
      __ndigit,
      __decpt,
      __sign,
      __buf,
      __len,
    );
  }

  late final _ecvt_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Double,
              ffi.Int,
              ffi.Pointer<ffi.Int>,
              ffi.Pointer<ffi.Int>,
              ffi.Pointer<ffi.Char>,
              ffi.Size)>>('ecvt_r');
  late final _ecvt_r = _ecvt_rPtr.asFunction<
      int Function(double, int, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>,
          ffi.Pointer<ffi.Char>, int)>();

  int fcvt_r(
    double __value,
    int __ndigit,
    ffi.Pointer<ffi.Int> __decpt,
    ffi.Pointer<ffi.Int> __sign,
    ffi.Pointer<ffi.Char> __buf,
    int __len,
  ) {
    return _fcvt_r(
      __value,
      __ndigit,
      __decpt,
      __sign,
      __buf,
      __len,
    );
  }

  late final _fcvt_rPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Double,
              ffi.Int,
              ffi.Pointer<ffi.Int>,
              ffi.Pointer<ffi.Int>,
              ffi.Pointer<ffi.Char>,
              ffi.Size)>>('fcvt_r');
  late final _fcvt_r = _fcvt_rPtr.asFunction<
      int Function(double, int, ffi.Pointer<ffi.Int>, ffi.Pointer<ffi.Int>,
          ffi.Pointer<ffi.Char>, int)>();

  int mblen(
    ffi.Pointer<ffi.Char> __s,
    int __n,
  ) {
    return _mblen(
      __s,
      __n,
    );
  }

  late final _mblenPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Size)>>('mblen');
  late final _mblen =
      _mblenPtr.asFunction<int Function(ffi.Pointer<ffi.Char>, int)>();

  int mbtowc(
    ffi.Pointer<ffi.WChar> __pwc,
    ffi.Pointer<ffi.Char> __s,
    int __n,
  ) {
    return _mbtowc(
      __pwc,
      __s,
      __n,
    );
  }

  late final _mbtowcPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.WChar>, ffi.Pointer<ffi.Char>,
              ffi.Size)>>('mbtowc');
  late final _mbtowc = _mbtowcPtr.asFunction<
      int Function(ffi.Pointer<ffi.WChar>, ffi.Pointer<ffi.Char>, int)>();

  int wctomb(
    ffi.Pointer<ffi.Char> __s,
    int __wchar,
  ) {
    return _wctomb(
      __s,
      __wchar,
    );
  }

  late final _wctombPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.WChar)>>('wctomb');
  late final _wctomb =
      _wctombPtr.asFunction<int Function(ffi.Pointer<ffi.Char>, int)>();

  int mbstowcs(
    ffi.Pointer<ffi.WChar> __pwcs,
    ffi.Pointer<ffi.Char> __s,
    int __n,
  ) {
    return _mbstowcs(
      __pwcs,
      __s,
      __n,
    );
  }

  late final _mbstowcsPtr = _lookup<
      ffi.NativeFunction<
          ffi.Size Function(ffi.Pointer<ffi.WChar>, ffi.Pointer<ffi.Char>,
              ffi.Size)>>('mbstowcs');
  late final _mbstowcs = _mbstowcsPtr.asFunction<
      int Function(ffi.Pointer<ffi.WChar>, ffi.Pointer<ffi.Char>, int)>();

  int wcstombs(
    ffi.Pointer<ffi.Char> __s,
    ffi.Pointer<ffi.WChar> __pwcs,
    int __n,
  ) {
    return _wcstombs(
      __s,
      __pwcs,
      __n,
    );
  }

  late final _wcstombsPtr = _lookup<
      ffi.NativeFunction<
          ffi.Size Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.WChar>,
              ffi.Size)>>('wcstombs');
  late final _wcstombs = _wcstombsPtr.asFunction<
      int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.WChar>, int)>();

  int rpmatch(
    ffi.Pointer<ffi.Char> __response,
  ) {
    return _rpmatch(
      __response,
    );
  }

  late final _rpmatchPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>)>>(
          'rpmatch');
  late final _rpmatch =
      _rpmatchPtr.asFunction<int Function(ffi.Pointer<ffi.Char>)>();

  int getsubopt(
    ffi.Pointer<ffi.Pointer<ffi.Char>> __optionp,
    ffi.Pointer<ffi.Pointer<ffi.Char>> __tokens,
    ffi.Pointer<ffi.Pointer<ffi.Char>> __valuep,
  ) {
    return _getsubopt(
      __optionp,
      __tokens,
      __valuep,
    );
  }

  late final _getsuboptPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<ffi.Pointer<ffi.Char>>,
              ffi.Pointer<ffi.Pointer<ffi.Char>>,
              ffi.Pointer<ffi.Pointer<ffi.Char>>)>>('getsubopt');
  late final _getsubopt = _getsuboptPtr.asFunction<
      int Function(
          ffi.Pointer<ffi.Pointer<ffi.Char>>,
          ffi.Pointer<ffi.Pointer<ffi.Char>>,
          ffi.Pointer<ffi.Pointer<ffi.Char>>)>();

  int getloadavg(
    ffi.Pointer<ffi.Double> __loadavg,
    int __nelem,
  ) {
    return _getloadavg(
      __loadavg,
      __nelem,
    );
  }

  late final _getloadavgPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<ffi.Double>, ffi.Int)>>('getloadavg');
  late final _getloadavg =
      _getloadavgPtr.asFunction<int Function(ffi.Pointer<ffi.Double>, int)>();

  /// Determine if the HD Version is public
  ///
  /// \param version HD version
  /// \return true if the version is public, false otherwise
  bool TWHDVersionIsPublic(
    int version,
  ) {
    return _TWHDVersionIsPublic(
      version,
    );
  }

  late final _TWHDVersionIsPublicPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Int32)>>(
          'TWHDVersionIsPublic');
  late final _TWHDVersionIsPublic =
      _TWHDVersionIsPublicPtr.asFunction<bool Function(int)>();

  /// Determine if the HD Version is private
  ///
  /// \param version HD version
  /// \return true if the version is private, false otherwise
  bool TWHDVersionIsPrivate(
    int version,
  ) {
    return _TWHDVersionIsPrivate(
      version,
    );
  }

  late final _TWHDVersionIsPrivatePtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Int32)>>(
          'TWHDVersionIsPrivate');
  late final _TWHDVersionIsPrivate =
      _TWHDVersionIsPrivatePtr.asFunction<bool Function(int)>();

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_BITCOIN =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_BITCOIN');

  ffi.Pointer<ffi.Char> get HRP_BITCOIN => _HRP_BITCOIN.value;

  set HRP_BITCOIN(ffi.Pointer<ffi.Char> value) => _HRP_BITCOIN.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_LITECOIN =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_LITECOIN');

  ffi.Pointer<ffi.Char> get HRP_LITECOIN => _HRP_LITECOIN.value;

  set HRP_LITECOIN(ffi.Pointer<ffi.Char> value) => _HRP_LITECOIN.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_VIACOIN =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_VIACOIN');

  ffi.Pointer<ffi.Char> get HRP_VIACOIN => _HRP_VIACOIN.value;

  set HRP_VIACOIN(ffi.Pointer<ffi.Char> value) => _HRP_VIACOIN.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_GROESTLCOIN =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_GROESTLCOIN');

  ffi.Pointer<ffi.Char> get HRP_GROESTLCOIN => _HRP_GROESTLCOIN.value;

  set HRP_GROESTLCOIN(ffi.Pointer<ffi.Char> value) =>
      _HRP_GROESTLCOIN.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_DIGIBYTE =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_DIGIBYTE');

  ffi.Pointer<ffi.Char> get HRP_DIGIBYTE => _HRP_DIGIBYTE.value;

  set HRP_DIGIBYTE(ffi.Pointer<ffi.Char> value) => _HRP_DIGIBYTE.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_MONACOIN =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_MONACOIN');

  ffi.Pointer<ffi.Char> get HRP_MONACOIN => _HRP_MONACOIN.value;

  set HRP_MONACOIN(ffi.Pointer<ffi.Char> value) => _HRP_MONACOIN.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_COSMOS =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_COSMOS');

  ffi.Pointer<ffi.Char> get HRP_COSMOS => _HRP_COSMOS.value;

  set HRP_COSMOS(ffi.Pointer<ffi.Char> value) => _HRP_COSMOS.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_BITCOINCASH =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_BITCOINCASH');

  ffi.Pointer<ffi.Char> get HRP_BITCOINCASH => _HRP_BITCOINCASH.value;

  set HRP_BITCOINCASH(ffi.Pointer<ffi.Char> value) =>
      _HRP_BITCOINCASH.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_BITCOINGOLD =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_BITCOINGOLD');

  ffi.Pointer<ffi.Char> get HRP_BITCOINGOLD => _HRP_BITCOINGOLD.value;

  set HRP_BITCOINGOLD(ffi.Pointer<ffi.Char> value) =>
      _HRP_BITCOINGOLD.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_IOTEX =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_IOTEX');

  ffi.Pointer<ffi.Char> get HRP_IOTEX => _HRP_IOTEX.value;

  set HRP_IOTEX(ffi.Pointer<ffi.Char> value) => _HRP_IOTEX.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_NERVOS =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_NERVOS');

  ffi.Pointer<ffi.Char> get HRP_NERVOS => _HRP_NERVOS.value;

  set HRP_NERVOS(ffi.Pointer<ffi.Char> value) => _HRP_NERVOS.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_ZILLIQA =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_ZILLIQA');

  ffi.Pointer<ffi.Char> get HRP_ZILLIQA => _HRP_ZILLIQA.value;

  set HRP_ZILLIQA(ffi.Pointer<ffi.Char> value) => _HRP_ZILLIQA.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_TERRA =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_TERRA');

  ffi.Pointer<ffi.Char> get HRP_TERRA => _HRP_TERRA.value;

  set HRP_TERRA(ffi.Pointer<ffi.Char> value) => _HRP_TERRA.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_CRYPTOORG =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_CRYPTOORG');

  ffi.Pointer<ffi.Char> get HRP_CRYPTOORG => _HRP_CRYPTOORG.value;

  set HRP_CRYPTOORG(ffi.Pointer<ffi.Char> value) =>
      _HRP_CRYPTOORG.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_KAVA =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_KAVA');

  ffi.Pointer<ffi.Char> get HRP_KAVA => _HRP_KAVA.value;

  set HRP_KAVA(ffi.Pointer<ffi.Char> value) => _HRP_KAVA.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_OASIS =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_OASIS');

  ffi.Pointer<ffi.Char> get HRP_OASIS => _HRP_OASIS.value;

  set HRP_OASIS(ffi.Pointer<ffi.Char> value) => _HRP_OASIS.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_BLUZELLE =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_BLUZELLE');

  ffi.Pointer<ffi.Char> get HRP_BLUZELLE => _HRP_BLUZELLE.value;

  set HRP_BLUZELLE(ffi.Pointer<ffi.Char> value) => _HRP_BLUZELLE.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_BAND =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_BAND');

  ffi.Pointer<ffi.Char> get HRP_BAND => _HRP_BAND.value;

  set HRP_BAND(ffi.Pointer<ffi.Char> value) => _HRP_BAND.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_ELROND =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_ELROND');

  ffi.Pointer<ffi.Char> get HRP_ELROND => _HRP_ELROND.value;

  set HRP_ELROND(ffi.Pointer<ffi.Char> value) => _HRP_ELROND.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_SECRET =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_SECRET');

  ffi.Pointer<ffi.Char> get HRP_SECRET => _HRP_SECRET.value;

  set HRP_SECRET(ffi.Pointer<ffi.Char> value) => _HRP_SECRET.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_AGORIC =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_AGORIC');

  ffi.Pointer<ffi.Char> get HRP_AGORIC => _HRP_AGORIC.value;

  set HRP_AGORIC(ffi.Pointer<ffi.Char> value) => _HRP_AGORIC.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_BINANCE =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_BINANCE');

  ffi.Pointer<ffi.Char> get HRP_BINANCE => _HRP_BINANCE.value;

  set HRP_BINANCE(ffi.Pointer<ffi.Char> value) => _HRP_BINANCE.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_ECASH =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_ECASH');

  ffi.Pointer<ffi.Char> get HRP_ECASH => _HRP_ECASH.value;

  set HRP_ECASH(ffi.Pointer<ffi.Char> value) => _HRP_ECASH.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_THORCHAIN =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_THORCHAIN');

  ffi.Pointer<ffi.Char> get HRP_THORCHAIN => _HRP_THORCHAIN.value;

  set HRP_THORCHAIN(ffi.Pointer<ffi.Char> value) =>
      _HRP_THORCHAIN.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_HARMONY =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_HARMONY');

  ffi.Pointer<ffi.Char> get HRP_HARMONY => _HRP_HARMONY.value;

  set HRP_HARMONY(ffi.Pointer<ffi.Char> value) => _HRP_HARMONY.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_CARDANO =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_CARDANO');

  ffi.Pointer<ffi.Char> get HRP_CARDANO => _HRP_CARDANO.value;

  set HRP_CARDANO(ffi.Pointer<ffi.Char> value) => _HRP_CARDANO.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_QTUM =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_QTUM');

  ffi.Pointer<ffi.Char> get HRP_QTUM => _HRP_QTUM.value;

  set HRP_QTUM(ffi.Pointer<ffi.Char> value) => _HRP_QTUM.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_NATIVEINJECTIVE =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_NATIVEINJECTIVE');

  ffi.Pointer<ffi.Char> get HRP_NATIVEINJECTIVE => _HRP_NATIVEINJECTIVE.value;

  set HRP_NATIVEINJECTIVE(ffi.Pointer<ffi.Char> value) =>
      _HRP_NATIVEINJECTIVE.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_OSMOSIS =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_OSMOSIS');

  ffi.Pointer<ffi.Char> get HRP_OSMOSIS => _HRP_OSMOSIS.value;

  set HRP_OSMOSIS(ffi.Pointer<ffi.Char> value) => _HRP_OSMOSIS.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_TERRAV2 =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_TERRAV2');

  ffi.Pointer<ffi.Char> get HRP_TERRAV2 => _HRP_TERRAV2.value;

  set HRP_TERRAV2(ffi.Pointer<ffi.Char> value) => _HRP_TERRAV2.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_STARGAZE =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_STARGAZE');

  ffi.Pointer<ffi.Char> get HRP_STARGAZE => _HRP_STARGAZE.value;

  set HRP_STARGAZE(ffi.Pointer<ffi.Char> value) => _HRP_STARGAZE.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_NATIVEEVMOS =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_NATIVEEVMOS');

  ffi.Pointer<ffi.Char> get HRP_NATIVEEVMOS => _HRP_NATIVEEVMOS.value;

  set HRP_NATIVEEVMOS(ffi.Pointer<ffi.Char> value) =>
      _HRP_NATIVEEVMOS.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_JUNO =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_JUNO');

  ffi.Pointer<ffi.Char> get HRP_JUNO => _HRP_JUNO.value;

  set HRP_JUNO(ffi.Pointer<ffi.Char> value) => _HRP_JUNO.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_STRIDE =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_STRIDE');

  ffi.Pointer<ffi.Char> get HRP_STRIDE => _HRP_STRIDE.value;

  set HRP_STRIDE(ffi.Pointer<ffi.Char> value) => _HRP_STRIDE.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_AXELAR =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_AXELAR');

  ffi.Pointer<ffi.Char> get HRP_AXELAR => _HRP_AXELAR.value;

  set HRP_AXELAR(ffi.Pointer<ffi.Char> value) => _HRP_AXELAR.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_CRESCENT =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_CRESCENT');

  ffi.Pointer<ffi.Char> get HRP_CRESCENT => _HRP_CRESCENT.value;

  set HRP_CRESCENT(ffi.Pointer<ffi.Char> value) => _HRP_CRESCENT.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _HRP_KUJIRA =
      _lookup<ffi.Pointer<ffi.Char>>('HRP_KUJIRA');

  ffi.Pointer<ffi.Char> get HRP_KUJIRA => _HRP_KUJIRA.value;

  set HRP_KUJIRA(ffi.Pointer<ffi.Char> value) => _HRP_KUJIRA.value = value;

  ffi.Pointer<ffi.Char> stringForHRP(
    int hrp,
  ) {
    return _stringForHRP(
      hrp,
    );
  }

  late final _stringForHRPPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Int32)>>(
          'stringForHRP');
  late final _stringForHRP =
      _stringForHRPPtr.asFunction<ffi.Pointer<ffi.Char> Function(int)>();

  int hrpForString(
    ffi.Pointer<ffi.Char> string,
  ) {
    return _hrpForString(
      string,
    );
  }

  late final _hrpForStringPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<ffi.Char>)>>(
          'hrpForString');
  late final _hrpForString =
      _hrpForStringPtr.asFunction<int Function(ffi.Pointer<ffi.Char>)>();

  /// Creates a TWString from a null-terminated UTF8 byte array. It must be deleted at the end.
  ///
  /// \param bytes a null-terminated UTF8 byte array.
  ffi.Pointer<TWString> TWStringCreateWithUTF8Bytes(
    ffi.Pointer<ffi.Char> bytes,
  ) {
    return _TWStringCreateWithUTF8Bytes(
      bytes,
    );
  }

  late final _TWStringCreateWithUTF8BytesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<ffi.Char>)>>('TWStringCreateWithUTF8Bytes');
  late final _TWStringCreateWithUTF8Bytes = _TWStringCreateWithUTF8BytesPtr
      .asFunction<ffi.Pointer<TWString> Function(ffi.Pointer<ffi.Char>)>();

  /// Creates a string from a raw byte array and size. It must be deleted at the end.
  ///
  /// \param bytes a raw byte array.
  /// \param size the size of the byte array.
  ffi.Pointer<TWString> TWStringCreateWithRawBytes(
    ffi.Pointer<ffi.Uint8> bytes,
    int size,
  ) {
    return _TWStringCreateWithRawBytes(
      bytes,
      size,
    );
  }

  late final _TWStringCreateWithRawBytesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<ffi.Uint8>, ffi.Size)>>('TWStringCreateWithRawBytes');
  late final _TWStringCreateWithRawBytes =
      _TWStringCreateWithRawBytesPtr.asFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<ffi.Uint8>, int)>();

  /// Creates a hexadecimal string from a block of data. It must be deleted at the end.
  ///
  /// \param data a block of data.
  ffi.Pointer<TWString> TWStringCreateWithHexData(
    ffi.Pointer<TWData> data,
  ) {
    return _TWStringCreateWithHexData(
      data,
    );
  }

  late final _TWStringCreateWithHexDataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWData>)>>('TWStringCreateWithHexData');
  late final _TWStringCreateWithHexData = _TWStringCreateWithHexDataPtr
      .asFunction<ffi.Pointer<TWString> Function(ffi.Pointer<TWData>)>();

  /// Returns the string size in bytes.
  ///
  /// \param string a TWString pointer.
  int TWStringSize(
    ffi.Pointer<TWString> string,
  ) {
    return _TWStringSize(
      string,
    );
  }

  late final _TWStringSizePtr =
      _lookup<ffi.NativeFunction<ffi.Size Function(ffi.Pointer<TWString>)>>(
          'TWStringSize');
  late final _TWStringSize =
      _TWStringSizePtr.asFunction<int Function(ffi.Pointer<TWString>)>();

  /// Returns the byte at the provided index.
  ///
  /// \param string a TWString pointer.
  /// \param index the index of the byte.
  int TWStringGet(
    ffi.Pointer<TWString> string,
    int index,
  ) {
    return _TWStringGet(
      string,
      index,
    );
  }

  late final _TWStringGetPtr = _lookup<
      ffi.NativeFunction<
          ffi.Char Function(ffi.Pointer<TWString>, ffi.Size)>>('TWStringGet');
  late final _TWStringGet =
      _TWStringGetPtr.asFunction<int Function(ffi.Pointer<TWString>, int)>();

  /// Returns the raw pointer to the string's UTF8 bytes (null-terminated).
  ///
  /// \param string a TWString pointer.
  ffi.Pointer<ffi.Char> TWStringUTF8Bytes(
    ffi.Pointer<TWString> string,
  ) {
    return _TWStringUTF8Bytes(
      string,
    );
  }

  late final _TWStringUTF8BytesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<TWString>)>>('TWStringUTF8Bytes');
  late final _TWStringUTF8Bytes = _TWStringUTF8BytesPtr.asFunction<
      ffi.Pointer<ffi.Char> Function(ffi.Pointer<TWString>)>();

  /// Deletes a string created with a `TWStringCreate*` method and frees the memory.
  ///
  /// \param string a TWString pointer.
  void TWStringDelete(
    ffi.Pointer<TWString> string,
  ) {
    return _TWStringDelete(
      string,
    );
  }

  late final _TWStringDeletePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWString>)>>(
          'TWStringDelete');
  late final _TWStringDelete =
      _TWStringDeletePtr.asFunction<void Function(ffi.Pointer<TWString>)>();

  /// Determines whether two string blocks are equal.
  ///
  /// \param lhs a TWString pointer.
  /// \param rhs another TWString pointer.
  bool TWStringEqual(
    ffi.Pointer<TWString> lhs,
    ffi.Pointer<TWString> rhs,
  ) {
    return _TWStringEqual(
      lhs,
      rhs,
    );
  }

  late final _TWStringEqualPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(
              ffi.Pointer<TWString>, ffi.Pointer<TWString>)>>('TWStringEqual');
  late final _TWStringEqual = _TWStringEqualPtr.asFunction<
      bool Function(ffi.Pointer<TWString>, ffi.Pointer<TWString>)>();

  /// Returns the blockchain for a coin type.
  ///
  /// \param coin A coin type
  /// \return blockchain associated to the given coin type
  int TWCoinTypeBlockchain(
    int coin,
  ) {
    return _TWCoinTypeBlockchain(
      coin,
    );
  }

  late final _TWCoinTypeBlockchainPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'TWCoinTypeBlockchain');
  late final _TWCoinTypeBlockchain =
      _TWCoinTypeBlockchainPtr.asFunction<int Function(int)>();

  /// Returns the purpose for a coin type.
  ///
  /// \param coin A coin type
  /// \return purpose associated to the given coin type
  int TWCoinTypePurpose(
    int coin,
  ) {
    return _TWCoinTypePurpose(
      coin,
    );
  }

  late final _TWCoinTypePurposePtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'TWCoinTypePurpose');
  late final _TWCoinTypePurpose =
      _TWCoinTypePurposePtr.asFunction<int Function(int)>();

  /// Returns the curve that should be used for a coin type.
  ///
  /// \param coin A coin type
  /// \return curve that should be used for the given coin type
  int TWCoinTypeCurve(
    int coin,
  ) {
    return _TWCoinTypeCurve(
      coin,
    );
  }

  late final _TWCoinTypeCurvePtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'TWCoinTypeCurve');
  late final _TWCoinTypeCurve =
      _TWCoinTypeCurvePtr.asFunction<int Function(int)>();

  /// Returns the xpub HD version that should be used for a coin type.
  ///
  /// \param coin A coin type
  /// \return xpub HD version that should be used for the given coin type
  int TWCoinTypeXpubVersion(
    int coin,
  ) {
    return _TWCoinTypeXpubVersion(
      coin,
    );
  }

  late final _TWCoinTypeXpubVersionPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'TWCoinTypeXpubVersion');
  late final _TWCoinTypeXpubVersion =
      _TWCoinTypeXpubVersionPtr.asFunction<int Function(int)>();

  /// Returns the xprv HD version that should be used for a coin type.
  ///
  /// \param coin A coin type
  /// \return the xprv HD version that should be used for the given coin type.
  int TWCoinTypeXprvVersion(
    int coin,
  ) {
    return _TWCoinTypeXprvVersion(
      coin,
    );
  }

  late final _TWCoinTypeXprvVersionPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'TWCoinTypeXprvVersion');
  late final _TWCoinTypeXprvVersion =
      _TWCoinTypeXprvVersionPtr.asFunction<int Function(int)>();

  /// Validates an address string.
  ///
  /// \param coin A coin type
  /// \param address A public address
  /// \return true if the address is a valid public address of the given coin, false otherwise.
  bool TWCoinTypeValidate(
    int coin,
    ffi.Pointer<TWString> address,
  ) {
    return _TWCoinTypeValidate(
      coin,
      address,
    );
  }

  late final _TWCoinTypeValidatePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(
              ffi.Int32, ffi.Pointer<TWString>)>>('TWCoinTypeValidate');
  late final _TWCoinTypeValidate = _TWCoinTypeValidatePtr.asFunction<
      bool Function(int, ffi.Pointer<TWString>)>();

  /// Returns the default derivation path for a particular coin.
  ///
  /// \param coin A coin type
  /// \return the default derivation path for the given coin type.
  ffi.Pointer<TWString> TWCoinTypeDerivationPath(
    int coin,
  ) {
    return _TWCoinTypeDerivationPath(
      coin,
    );
  }

  late final _TWCoinTypeDerivationPathPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<TWString> Function(ffi.Int32)>>(
          'TWCoinTypeDerivationPath');
  late final _TWCoinTypeDerivationPath = _TWCoinTypeDerivationPathPtr
      .asFunction<ffi.Pointer<TWString> Function(int)>();

  /// Returns the derivation path for a particular coin with the explicit given derivation.
  ///
  /// \param coin A coin type
  /// \param derivation A derivation type
  /// \return the derivation path for the given coin with the explicit given derivation
  ffi.Pointer<TWString> TWCoinTypeDerivationPathWithDerivation(
    int coin,
    int derivation,
  ) {
    return _TWCoinTypeDerivationPathWithDerivation(
      coin,
      derivation,
    );
  }

  late final _TWCoinTypeDerivationPathWithDerivationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Int32, ffi.Int32)>>('TWCoinTypeDerivationPathWithDerivation');
  late final _TWCoinTypeDerivationPathWithDerivation =
      _TWCoinTypeDerivationPathWithDerivationPtr.asFunction<
          ffi.Pointer<TWString> Function(int, int)>();

  /// Derives the address for a particular coin from the private key.
  ///
  /// \param coin A coin type
  /// \param privateKey A valid private key
  /// \return Derived address for the given coin from the private key.
  ffi.Pointer<TWString> TWCoinTypeDeriveAddress(
    int coin,
    ffi.Pointer<TWPrivateKey> privateKey,
  ) {
    return _TWCoinTypeDeriveAddress(
      coin,
      privateKey,
    );
  }

  late final _TWCoinTypeDeriveAddressPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(ffi.Int32,
              ffi.Pointer<TWPrivateKey>)>>('TWCoinTypeDeriveAddress');
  late final _TWCoinTypeDeriveAddress = _TWCoinTypeDeriveAddressPtr.asFunction<
      ffi.Pointer<TWString> Function(int, ffi.Pointer<TWPrivateKey>)>();

  /// Derives the address for a particular coin from the public key.
  ///
  /// \param coin A coin type
  /// \param publicKey A valid public key
  /// \return Derived address for the given coin from the public key.
  ffi.Pointer<TWString> TWCoinTypeDeriveAddressFromPublicKey(
    int coin,
    ffi.Pointer<TWPublicKey> publicKey,
  ) {
    return _TWCoinTypeDeriveAddressFromPublicKey(
      coin,
      publicKey,
    );
  }

  late final _TWCoinTypeDeriveAddressFromPublicKeyPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWString> Function(
                  ffi.Int32, ffi.Pointer<TWPublicKey>)>>(
      'TWCoinTypeDeriveAddressFromPublicKey');
  late final _TWCoinTypeDeriveAddressFromPublicKey =
      _TWCoinTypeDeriveAddressFromPublicKeyPtr.asFunction<
          ffi.Pointer<TWString> Function(int, ffi.Pointer<TWPublicKey>)>();

  /// HRP for this coin type
  ///
  /// \param coin A coin type
  /// \return HRP of the given coin type.
  int TWCoinTypeHRP(
    int coin,
  ) {
    return _TWCoinTypeHRP(
      coin,
    );
  }

  late final _TWCoinTypeHRPPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'TWCoinTypeHRP');
  late final _TWCoinTypeHRP = _TWCoinTypeHRPPtr.asFunction<int Function(int)>();

  /// P2PKH prefix for this coin type
  ///
  /// \param coin A coin type
  /// \return P2PKH prefix for the given coin type
  int TWCoinTypeP2pkhPrefix(
    int coin,
  ) {
    return _TWCoinTypeP2pkhPrefix(
      coin,
    );
  }

  late final _TWCoinTypeP2pkhPrefixPtr =
      _lookup<ffi.NativeFunction<ffi.Uint8 Function(ffi.Int32)>>(
          'TWCoinTypeP2pkhPrefix');
  late final _TWCoinTypeP2pkhPrefix =
      _TWCoinTypeP2pkhPrefixPtr.asFunction<int Function(int)>();

  /// P2SH prefix for this coin type
  ///
  /// \param coin A coin type
  /// \return P2SH prefix for the given coin type
  int TWCoinTypeP2shPrefix(
    int coin,
  ) {
    return _TWCoinTypeP2shPrefix(
      coin,
    );
  }

  late final _TWCoinTypeP2shPrefixPtr =
      _lookup<ffi.NativeFunction<ffi.Uint8 Function(ffi.Int32)>>(
          'TWCoinTypeP2shPrefix');
  late final _TWCoinTypeP2shPrefix =
      _TWCoinTypeP2shPrefixPtr.asFunction<int Function(int)>();

  /// Static prefix for this coin type
  ///
  /// \param coin A coin type
  /// \return Static prefix for the given coin type
  int TWCoinTypeStaticPrefix(
    int coin,
  ) {
    return _TWCoinTypeStaticPrefix(
      coin,
    );
  }

  late final _TWCoinTypeStaticPrefixPtr =
      _lookup<ffi.NativeFunction<ffi.Uint8 Function(ffi.Int32)>>(
          'TWCoinTypeStaticPrefix');
  late final _TWCoinTypeStaticPrefix =
      _TWCoinTypeStaticPrefixPtr.asFunction<int Function(int)>();

  /// ChainID for this coin type.
  ///
  /// \param coin A coin type
  /// \return ChainID for the given coin type.
  /// \note Caller must free returned object.
  ffi.Pointer<TWString> TWCoinTypeChainId(
    int coin,
  ) {
    return _TWCoinTypeChainId(
      coin,
    );
  }

  late final _TWCoinTypeChainIdPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<TWString> Function(ffi.Int32)>>(
          'TWCoinTypeChainId');
  late final _TWCoinTypeChainId =
      _TWCoinTypeChainIdPtr.asFunction<ffi.Pointer<TWString> Function(int)>();

  /// SLIP-0044 id for this coin type
  ///
  /// \param coin A coin type
  /// \return SLIP-0044 id for the given coin type
  int TWCoinTypeSlip44Id(
    int coin,
  ) {
    return _TWCoinTypeSlip44Id(
      coin,
    );
  }

  late final _TWCoinTypeSlip44IdPtr =
      _lookup<ffi.NativeFunction<ffi.Uint32 Function(ffi.Int32)>>(
          'TWCoinTypeSlip44Id');
  late final _TWCoinTypeSlip44Id =
      _TWCoinTypeSlip44IdPtr.asFunction<int Function(int)>();

  /// SS58Prefix for this coin type
  ///
  /// \param coin A coin type
  /// \return SS58Prefix for the given coin type
  int TWCoinTypeSS58Prefix(
    int coin,
  ) {
    return _TWCoinTypeSS58Prefix(
      coin,
    );
  }

  late final _TWCoinTypeSS58PrefixPtr =
      _lookup<ffi.NativeFunction<ffi.Uint32 Function(ffi.Int32)>>(
          'TWCoinTypeSS58Prefix');
  late final _TWCoinTypeSS58Prefix =
      _TWCoinTypeSS58PrefixPtr.asFunction<int Function(int)>();

  /// public key type for this coin type
  ///
  /// \param coin A coin type
  /// \return public key type for the given coin type
  int TWCoinTypePublicKeyType(
    int coin,
  ) {
    return _TWCoinTypePublicKeyType(
      coin,
    );
  }

  late final _TWCoinTypePublicKeyTypePtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'TWCoinTypePublicKeyType');
  late final _TWCoinTypePublicKeyType =
      _TWCoinTypePublicKeyTypePtr.asFunction<int Function(int)>();

  /// Creates a new Account with an address, a coin type, derivation enum, derivationPath, publicKey,
  /// and extendedPublicKey. Must be deleted with TWAccountDelete after use.
  ///
  /// \param address The address of the Account.
  /// \param coin The coin type of the Account.
  /// \param derivation The derivation of the Account.
  /// \param derivationPath The derivation path of the Account.
  /// \param publicKey hex encoded public key.
  /// \param extendedPublicKey Base58 encoded extended public key.
  /// \return A new Account.
  ffi.Pointer<TWAccount> TWAccountCreate(
    ffi.Pointer<TWString> address,
    int coin,
    int derivation,
    ffi.Pointer<TWString> derivationPath,
    ffi.Pointer<TWString> publicKey,
    ffi.Pointer<TWString> extendedPublicKey,
  ) {
    return _TWAccountCreate(
      address,
      coin,
      derivation,
      derivationPath,
      publicKey,
      extendedPublicKey,
    );
  }

  late final _TWAccountCreatePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWAccount> Function(
              ffi.Pointer<TWString>,
              ffi.Int32,
              ffi.Int32,
              ffi.Pointer<TWString>,
              ffi.Pointer<TWString>,
              ffi.Pointer<TWString>)>>('TWAccountCreate');
  late final _TWAccountCreate = _TWAccountCreatePtr.asFunction<
      ffi.Pointer<TWAccount> Function(
          ffi.Pointer<TWString>,
          int,
          int,
          ffi.Pointer<TWString>,
          ffi.Pointer<TWString>,
          ffi.Pointer<TWString>)>();

  /// Deletes an account.
  ///
  /// \param account Account to delete.
  void TWAccountDelete(
    ffi.Pointer<TWAccount> account,
  ) {
    return _TWAccountDelete(
      account,
    );
  }

  late final _TWAccountDeletePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWAccount>)>>(
          'TWAccountDelete');
  late final _TWAccountDelete =
      _TWAccountDeletePtr.asFunction<void Function(ffi.Pointer<TWAccount>)>();

  /// Returns the address of an account.
  ///
  /// \param account Account to get the address of.
  ffi.Pointer<TWString> TWAccountAddress(
    ffi.Pointer<TWAccount> account,
  ) {
    return _TWAccountAddress(
      account,
    );
  }

  late final _TWAccountAddressPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWAccount>)>>('TWAccountAddress');
  late final _TWAccountAddress = _TWAccountAddressPtr.asFunction<
      ffi.Pointer<TWString> Function(ffi.Pointer<TWAccount>)>();

  /// Return CoinType enum of an account.
  ///
  /// \param account Account to get the coin type of.
  int TWAccountCoin(
    ffi.Pointer<TWAccount> account,
  ) {
    return _TWAccountCoin(
      account,
    );
  }

  late final _TWAccountCoinPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<TWAccount>)>>(
          'TWAccountCoin');
  late final _TWAccountCoin =
      _TWAccountCoinPtr.asFunction<int Function(ffi.Pointer<TWAccount>)>();

  /// Returns the derivation enum of an account.
  ///
  /// \param account Account to get the derivation enum of.
  int TWAccountDerivation(
    ffi.Pointer<TWAccount> account,
  ) {
    return _TWAccountDerivation(
      account,
    );
  }

  late final _TWAccountDerivationPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<TWAccount>)>>(
          'TWAccountDerivation');
  late final _TWAccountDerivation = _TWAccountDerivationPtr.asFunction<
      int Function(ffi.Pointer<TWAccount>)>();

  /// Returns derivationPath of an account.
  ///
  /// \param account Account to get the derivation path of.
  ffi.Pointer<TWString> TWAccountDerivationPath(
    ffi.Pointer<TWAccount> account,
  ) {
    return _TWAccountDerivationPath(
      account,
    );
  }

  late final _TWAccountDerivationPathPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWAccount>)>>('TWAccountDerivationPath');
  late final _TWAccountDerivationPath = _TWAccountDerivationPathPtr.asFunction<
      ffi.Pointer<TWString> Function(ffi.Pointer<TWAccount>)>();

  /// Returns hex encoded publicKey of an account.
  ///
  /// \param account Account to get the public key of.
  ffi.Pointer<TWString> TWAccountPublicKey(
    ffi.Pointer<TWAccount> account,
  ) {
    return _TWAccountPublicKey(
      account,
    );
  }

  late final _TWAccountPublicKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWAccount>)>>('TWAccountPublicKey');
  late final _TWAccountPublicKey = _TWAccountPublicKeyPtr.asFunction<
      ffi.Pointer<TWString> Function(ffi.Pointer<TWAccount>)>();

  /// Returns Base58 encoded extendedPublicKey of an account.
  ///
  /// \param account Account to get the extended public key of.
  ffi.Pointer<TWString> TWAccountExtendedPublicKey(
    ffi.Pointer<TWAccount> account,
  ) {
    return _TWAccountExtendedPublicKey(
      account,
    );
  }

  late final _TWAccountExtendedPublicKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWAccount>)>>('TWAccountExtendedPublicKey');
  late final _TWAccountExtendedPublicKey = _TWAccountExtendedPublicKeyPtr
      .asFunction<ffi.Pointer<TWString> Function(ffi.Pointer<TWAccount>)>();
}

class max_align_t extends ffi.Opaque {}

class __fsid_t extends ffi.Struct {
  @ffi.Array.multi([2])
  external ffi.Array<ffi.Int> __val;
}

class div_t extends ffi.Struct {
  @ffi.Int()
  external int quot;

  @ffi.Int()
  external int rem;
}

class ldiv_t extends ffi.Struct {
  @ffi.Long()
  external int quot;

  @ffi.Long()
  external int rem;
}

class lldiv_t extends ffi.Struct {
  @ffi.LongLong()
  external int quot;

  @ffi.LongLong()
  external int rem;
}

class __sigset_t extends ffi.Struct {
  @ffi.Array.multi([16])
  external ffi.Array<ffi.UnsignedLong> __val;
}

class timeval extends ffi.Struct {
  @__time_t()
  external int tv_sec;

  @__suseconds_t()
  external int tv_usec;
}

typedef __time_t = ffi.Long;
typedef __suseconds_t = ffi.Long;

class timespec extends ffi.Struct {
  @__time_t()
  external int tv_sec;

  @__syscall_slong_t()
  external int tv_nsec;
}

typedef __syscall_slong_t = ffi.Long;

class fd_set extends ffi.Struct {
  @ffi.Array.multi([16])
  external ffi.Array<__fd_mask> __fds_bits;
}

typedef __fd_mask = ffi.Long;

class __atomic_wide_counter extends ffi.Union {
  @ffi.UnsignedLongLong()
  external int __value64;

  external UnnamedStruct1 __value32;
}

class UnnamedStruct1 extends ffi.Struct {
  @ffi.UnsignedInt()
  external int __low;

  @ffi.UnsignedInt()
  external int __high;
}

class __pthread_internal_list extends ffi.Struct {
  external ffi.Pointer<__pthread_internal_list> __prev;

  external ffi.Pointer<__pthread_internal_list> __next;
}

class __pthread_internal_slist extends ffi.Struct {
  external ffi.Pointer<__pthread_internal_slist> __next;
}

class __pthread_mutex_s extends ffi.Struct {
  @ffi.Int()
  external int __lock;

  @ffi.UnsignedInt()
  external int __count;

  @ffi.Int()
  external int __owner;

  @ffi.UnsignedInt()
  external int __nusers;

  @ffi.Int()
  external int __kind;

  @ffi.Short()
  external int __spins;

  @ffi.Short()
  external int __elision;

  external __pthread_list_t __list;
}

typedef __pthread_list_t = __pthread_internal_list;

class __pthread_rwlock_arch_t extends ffi.Struct {
  @ffi.UnsignedInt()
  external int __readers;

  @ffi.UnsignedInt()
  external int __writers;

  @ffi.UnsignedInt()
  external int __wrphase_futex;

  @ffi.UnsignedInt()
  external int __writers_futex;

  @ffi.UnsignedInt()
  external int __pad3;

  @ffi.UnsignedInt()
  external int __pad4;

  @ffi.Int()
  external int __cur_writer;

  @ffi.Int()
  external int __shared;

  @ffi.SignedChar()
  external int __rwelision;

  @ffi.Array.multi([7])
  external ffi.Array<ffi.UnsignedChar> __pad1;

  @ffi.UnsignedLong()
  external int __pad2;

  @ffi.UnsignedInt()
  external int __flags;
}

class __pthread_cond_s extends ffi.Struct {
  external __atomic_wide_counter __wseq;

  external __atomic_wide_counter __g1_start;

  @ffi.Array.multi([2])
  external ffi.Array<ffi.UnsignedInt> __g_refs;

  @ffi.Array.multi([2])
  external ffi.Array<ffi.UnsignedInt> __g_size;

  @ffi.UnsignedInt()
  external int __g1_orig_size;

  @ffi.UnsignedInt()
  external int __wrefs;

  @ffi.Array.multi([2])
  external ffi.Array<ffi.UnsignedInt> __g_signals;
}

class __once_flag extends ffi.Struct {
  @ffi.Int()
  external int __data;
}

class pthread_mutexattr_t extends ffi.Union {
  @ffi.Array.multi([4])
  external ffi.Array<ffi.Char> __size;

  @ffi.Int()
  external int __align;
}

class pthread_condattr_t extends ffi.Union {
  @ffi.Array.multi([4])
  external ffi.Array<ffi.Char> __size;

  @ffi.Int()
  external int __align;
}

class pthread_attr_t extends ffi.Union {
  @ffi.Array.multi([56])
  external ffi.Array<ffi.Char> __size;

  @ffi.Long()
  external int __align;
}

class pthread_mutex_t extends ffi.Union {
  external __pthread_mutex_s __data;

  @ffi.Array.multi([40])
  external ffi.Array<ffi.Char> __size;

  @ffi.Long()
  external int __align;
}

class pthread_cond_t extends ffi.Union {
  external __pthread_cond_s __data;

  @ffi.Array.multi([48])
  external ffi.Array<ffi.Char> __size;

  @ffi.LongLong()
  external int __align;
}

class pthread_rwlock_t extends ffi.Union {
  external __pthread_rwlock_arch_t __data;

  @ffi.Array.multi([56])
  external ffi.Array<ffi.Char> __size;

  @ffi.Long()
  external int __align;
}

class pthread_rwlockattr_t extends ffi.Union {
  @ffi.Array.multi([8])
  external ffi.Array<ffi.Char> __size;

  @ffi.Long()
  external int __align;
}

class pthread_barrier_t extends ffi.Union {
  @ffi.Array.multi([32])
  external ffi.Array<ffi.Char> __size;

  @ffi.Long()
  external int __align;
}

class pthread_barrierattr_t extends ffi.Union {
  @ffi.Array.multi([4])
  external ffi.Array<ffi.Char> __size;

  @ffi.Int()
  external int __align;
}

class random_data extends ffi.Struct {
  external ffi.Pointer<ffi.Int32> fptr;

  external ffi.Pointer<ffi.Int32> rptr;

  external ffi.Pointer<ffi.Int32> state;

  @ffi.Int()
  external int rand_type;

  @ffi.Int()
  external int rand_deg;

  @ffi.Int()
  external int rand_sep;

  external ffi.Pointer<ffi.Int32> end_ptr;
}

class drand48_data extends ffi.Struct {
  @ffi.Array.multi([3])
  external ffi.Array<ffi.UnsignedShort> __x;

  @ffi.Array.multi([3])
  external ffi.Array<ffi.UnsignedShort> __old_x;

  @ffi.UnsignedShort()
  external int __c;

  @ffi.UnsignedShort()
  external int __init;

  @ffi.UnsignedLongLong()
  external int __a;
}

typedef __compar_fn_t = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Void>)>>;

/// Blockchain enum type
abstract class TWBlockchain {
  static const int TWBlockchainBitcoin = 0;
  static const int TWBlockchainEthereum = 1;
  static const int TWBlockchainVechain = 3;
  static const int TWBlockchainTron = 4;
  static const int TWBlockchainIcon = 5;
  static const int TWBlockchainBinance = 6;
  static const int TWBlockchainRipple = 7;
  static const int TWBlockchainTezos = 8;
  static const int TWBlockchainNimiq = 9;
  static const int TWBlockchainStellar = 10;
  static const int TWBlockchainAion = 11;
  static const int TWBlockchainCosmos = 12;
  static const int TWBlockchainTheta = 13;
  static const int TWBlockchainOntology = 14;
  static const int TWBlockchainZilliqa = 15;
  static const int TWBlockchainIoTeX = 16;
  static const int TWBlockchainEOS = 17;
  static const int TWBlockchainNano = 18;
  static const int TWBlockchainNULS = 19;
  static const int TWBlockchainWaves = 20;
  static const int TWBlockchainAeternity = 21;
  static const int TWBlockchainNebulas = 22;
  static const int TWBlockchainFIO = 23;
  static const int TWBlockchainSolana = 24;
  static const int TWBlockchainHarmony = 25;
  static const int TWBlockchainNEAR = 26;
  static const int TWBlockchainAlgorand = 27;
  static const int TWBlockchainPolkadot = 29;
  static const int TWBlockchainCardano = 30;
  static const int TWBlockchainNEO = 31;
  static const int TWBlockchainFilecoin = 32;
  static const int TWBlockchainMultiversX = 33;
  static const int TWBlockchainOasisNetwork = 34;
  static const int TWBlockchainDecred = 35;
  static const int TWBlockchainZcash = 36;
  static const int TWBlockchainGroestlcoin = 37;
  static const int TWBlockchainThorchain = 38;
  static const int TWBlockchainRonin = 39;
  static const int TWBlockchainKusama = 40;
  static const int TWBlockchainNervos = 41;
  static const int TWBlockchainEverscale = 42;
  static const int TWBlockchainAptos = 43;
  static const int TWBlockchainHedera = 44;
  static const int TWBlockchainTheOpenNetwork = 45;
  static const int TWBlockchainSui = 46;
}

/// Elliptic cruves
abstract class TWCurve {
  static const int TWCurveSECP256k1 = 0;
  static const int TWCurveED25519 = 1;
  static const int TWCurveED25519Blake2bNano = 2;
  static const int TWCurveCurve25519 = 3;
  static const int TWCurveNIST256p1 = 4;
  static const int TWCurveED25519ExtendedCardano = 5;
  static const int TWCurveStarkex = 6;
  static const int TWCurveNone = 7;
}

/// Registered HD version bytes
///
/// \see https://github.com/satoshilabs/slips/blob/master/slip-0132.md
abstract class TWHDVersion {
  static const int TWHDVersionNone = 0;
  static const int TWHDVersionXPUB = 76067358;
  static const int TWHDVersionXPRV = 76066276;
  static const int TWHDVersionYPUB = 77429938;
  static const int TWHDVersionYPRV = 77428856;
  static const int TWHDVersionZPUB = 78792518;
  static const int TWHDVersionZPRV = 78791436;
  static const int TWHDVersionLTUB = 27108450;
  static const int TWHDVersionLTPV = 27106558;
  static const int TWHDVersionMTUB = 28471030;
  static const int TWHDVersionMTPV = 28469138;
  static const int TWHDVersionDPUB = 50178342;
  static const int TWHDVersionDPRV = 50177256;
  static const int TWHDVersionDGUB = 49990397;
  static const int TWHDVersionDGPV = 49988504;
}

/// Registered human-readable parts for BIP-0173
///
/// - SeeAlso: https://github.com/satoshilabs/slips/blob/master/slip-0173.md
abstract class TWHRP {
  static const int TWHRPUnknown = 0;
  static const int TWHRPBitcoin = 1;
  static const int TWHRPLitecoin = 2;
  static const int TWHRPViacoin = 3;
  static const int TWHRPGroestlcoin = 4;
  static const int TWHRPDigiByte = 5;
  static const int TWHRPMonacoin = 6;
  static const int TWHRPCosmos = 7;
  static const int TWHRPBitcoinCash = 8;
  static const int TWHRPBitcoinGold = 9;
  static const int TWHRPIoTeX = 10;
  static const int TWHRPNervos = 11;
  static const int TWHRPZilliqa = 12;
  static const int TWHRPTerra = 13;
  static const int TWHRPCryptoOrg = 14;
  static const int TWHRPKava = 15;
  static const int TWHRPOasis = 16;
  static const int TWHRPBluzelle = 17;
  static const int TWHRPBandChain = 18;
  static const int TWHRPMultiversX = 19;
  static const int TWHRPSecret = 20;
  static const int TWHRPAgoric = 21;
  static const int TWHRPBinance = 22;
  static const int TWHRPECash = 23;
  static const int TWHRPTHORChain = 24;
  static const int TWHRPHarmony = 25;
  static const int TWHRPCardano = 26;
  static const int TWHRPQtum = 27;
  static const int TWHRPNativeInjective = 28;
  static const int TWHRPOsmosis = 29;
  static const int TWHRPTerraV2 = 30;
  static const int TWHRPStargaze = 31;
  static const int TWHRPNativeEvmos = 32;
  static const int TWHRPJuno = 33;
  static const int TWHRPStride = 34;
  static const int TWHRPAxelar = 35;
  static const int TWHRPCrescent = 36;
  static const int TWHRPKujira = 37;
}

/// HD wallet purpose
///
/// \see https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
/// \see https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki
/// \see https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki
abstract class TWPurpose {
  static const int TWPurposeBIP44 = 44;
  static const int TWPurposeBIP49 = 49;
  static const int TWPurposeBIP84 = 84;
  static const int TWPurposeBIP1852 = 1852;
}

/// Defines a resizable string.
///
/// The implementantion of these methods should be language-specific to minimize translation
/// overhead. For instance it should be a `jstring` for Java and an `NSString` for Swift. Create
/// allocates memory, the delete call should be called at the end to release memory.
typedef TWString = ffi.Void;
typedef TWData = ffi.Void;

/// Non-default coin address derivation names (default, unnamed derivations are not included).
abstract class TWDerivation {
  static const int TWDerivationDefault = 0;
  static const int TWDerivationCustom = 1;
  static const int TWDerivationBitcoinSegwit = 2;
  static const int TWDerivationBitcoinLegacy = 3;
  static const int TWDerivationBitcoinTestnet = 4;
  static const int TWDerivationLitecoinLegacy = 5;
  static const int TWDerivationSolanaSolana = 6;
}

/// Public key types
abstract class TWPublicKeyType {
  static const int TWPublicKeyTypeSECP256k1 = 0;
  static const int TWPublicKeyTypeSECP256k1Extended = 1;
  static const int TWPublicKeyTypeNIST256p1 = 2;
  static const int TWPublicKeyTypeNIST256p1Extended = 3;
  static const int TWPublicKeyTypeED25519 = 4;
  static const int TWPublicKeyTypeED25519Blake2b = 5;
  static const int TWPublicKeyTypeCURVE25519 = 6;
  static const int TWPublicKeyTypeED25519Cardano = 7;
  static const int TWPublicKeyTypeStarkex = 8;
}

/// Represents a private key.
class TWPrivateKey extends ffi.Opaque {}

/// Represents a public key.
class TWPublicKey extends ffi.Opaque {}

/// Coin type for Level 2 of BIP44.
///
/// \see https://github.com/satoshilabs/slips/blob/master/slip-0044.md
abstract class TWCoinType {
  static const int TWCoinTypeAeternity = 457;
  static const int TWCoinTypeAion = 425;
  static const int TWCoinTypeBinance = 714;
  static const int TWCoinTypeBitcoin = 0;
  static const int TWCoinTypeBitcoinCash = 145;
  static const int TWCoinTypeBitcoinGold = 156;
  static const int TWCoinTypeCallisto = 820;
  static const int TWCoinTypeCardano = 1815;
  static const int TWCoinTypeCosmos = 118;
  static const int TWCoinTypeDash = 5;
  static const int TWCoinTypeDecred = 42;
  static const int TWCoinTypeDigiByte = 20;
  static const int TWCoinTypeDogecoin = 3;
  static const int TWCoinTypeEOS = 194;
  static const int TWCoinTypeWAX = 14001;
  static const int TWCoinTypeEthereum = 60;
  static const int TWCoinTypeEthereumClassic = 61;
  static const int TWCoinTypeFIO = 235;
  static const int TWCoinTypeGoChain = 6060;
  static const int TWCoinTypeGroestlcoin = 17;
  static const int TWCoinTypeICON = 74;
  static const int TWCoinTypeIoTeX = 304;
  static const int TWCoinTypeKava = 459;
  static const int TWCoinTypeKin = 2017;
  static const int TWCoinTypeLitecoin = 2;
  static const int TWCoinTypeMonacoin = 22;
  static const int TWCoinTypeNebulas = 2718;
  static const int TWCoinTypeNULS = 8964;
  static const int TWCoinTypeNano = 165;
  static const int TWCoinTypeNEAR = 397;
  static const int TWCoinTypeNimiq = 242;
  static const int TWCoinTypeOntology = 1024;
  static const int TWCoinTypePOANetwork = 178;
  static const int TWCoinTypeQtum = 2301;
  static const int TWCoinTypeXRP = 144;
  static const int TWCoinTypeSolana = 501;
  static const int TWCoinTypeStellar = 148;
  static const int TWCoinTypeTezos = 1729;
  static const int TWCoinTypeTheta = 500;
  static const int TWCoinTypeThunderCore = 1001;
  static const int TWCoinTypeNEO = 888;
  static const int TWCoinTypeTomoChain = 889;
  static const int TWCoinTypeTron = 195;
  static const int TWCoinTypeVeChain = 818;
  static const int TWCoinTypeViacoin = 14;
  static const int TWCoinTypeWanchain = 5718350;
  static const int TWCoinTypeZcash = 133;
  static const int TWCoinTypeFiro = 136;
  static const int TWCoinTypeZilliqa = 313;
  static const int TWCoinTypeZelcash = 19167;
  static const int TWCoinTypeRavencoin = 175;
  static const int TWCoinTypeWaves = 5741564;
  static const int TWCoinTypeTerra = 330;
  static const int TWCoinTypeTerraV2 = 10000330;
  static const int TWCoinTypeHarmony = 1023;
  static const int TWCoinTypeAlgorand = 283;
  static const int TWCoinTypeKusama = 434;
  static const int TWCoinTypePolkadot = 354;
  static const int TWCoinTypeFilecoin = 461;
  static const int TWCoinTypeMultiversX = 508;
  static const int TWCoinTypeBandChain = 494;
  static const int TWCoinTypeSmartChainLegacy = 10000714;
  static const int TWCoinTypeSmartChain = 20000714;
  static const int TWCoinTypeOasis = 474;
  static const int TWCoinTypePolygon = 966;
  static const int TWCoinTypeTHORChain = 931;
  static const int TWCoinTypeBluzelle = 483;
  static const int TWCoinTypeOptimism = 10000070;
  static const int TWCoinTypeZksync = 10000324;
  static const int TWCoinTypeArbitrum = 10042221;
  static const int TWCoinTypeECOChain = 10000553;
  static const int TWCoinTypeAvalancheCChain = 10009000;
  static const int TWCoinTypeXDai = 10000100;
  static const int TWCoinTypeFantom = 10000250;
  static const int TWCoinTypeCryptoOrg = 394;
  static const int TWCoinTypeCelo = 52752;
  static const int TWCoinTypeRonin = 10002020;
  static const int TWCoinTypeOsmosis = 10000118;
  static const int TWCoinTypeECash = 899;
  static const int TWCoinTypeCronosChain = 10000025;
  static const int TWCoinTypeSmartBitcoinCash = 10000145;
  static const int TWCoinTypeKuCoinCommunityChain = 10000321;
  static const int TWCoinTypeBoba = 10000288;
  static const int TWCoinTypeMetis = 1001088;
  static const int TWCoinTypeAurora = 1323161554;
  static const int TWCoinTypeEvmos = 10009001;
  static const int TWCoinTypeNativeEvmos = 20009001;
  static const int TWCoinTypeMoonriver = 10001285;
  static const int TWCoinTypeMoonbeam = 10001284;
  static const int TWCoinTypeKavaEvm = 10002222;
  static const int TWCoinTypeKlaytn = 10008217;
  static const int TWCoinTypeMeter = 18000;
  static const int TWCoinTypeOKXChain = 996;
  static const int TWCoinTypeNervos = 309;
  static const int TWCoinTypeEverscale = 396;
  static const int TWCoinTypeAptos = 637;
  static const int TWCoinTypeHedera = 3030;
  static const int TWCoinTypeSecret = 529;
  static const int TWCoinTypeNativeInjective = 10000060;
  static const int TWCoinTypeAgoric = 564;
  static const int TWCoinTypeTON = 607;
  static const int TWCoinTypeSui = 784;
  static const int TWCoinTypeStargaze = 20000118;
  static const int TWCoinTypePolygonzkEVM = 10001101;
  static const int TWCoinTypeJuno = 30000118;
  static const int TWCoinTypeStride = 40000118;
  static const int TWCoinTypeAxelar = 50000118;
  static const int TWCoinTypeCrescent = 60000118;
  static const int TWCoinTypeKujira = 70000118;
}

/// Represents an Account in C++ with address, coin type and public key info, an item within a keystore.
class TWAccount extends ffi.Opaque {}

const int true1 = 1;

const int false1 = 0;

const int __bool_true_false_are_defined = 1;

const int NULL = 0;

const int _STDINT_H = 1;

const int _FEATURES_H = 1;

const int _DEFAULT_SOURCE = 1;

const int __GLIBC_USE_ISOC2X = 1;

const int __USE_ISOC11 = 1;

const int __USE_ISOC99 = 1;

const int __USE_ISOC95 = 1;

const int _POSIX_SOURCE = 1;

const int _POSIX_C_SOURCE = 200809;

const int __USE_POSIX = 1;

const int __USE_POSIX2 = 1;

const int __USE_POSIX199309 = 1;

const int __USE_POSIX199506 = 1;

const int __USE_XOPEN2K = 1;

const int __USE_XOPEN2K8 = 1;

const int _ATFILE_SOURCE = 1;

const int __WORDSIZE = 64;

const int __WORDSIZE_TIME64_COMPAT32 = 1;

const int __SYSCALL_WORDSIZE = 64;

const int __TIMESIZE = 64;

const int __USE_MISC = 1;

const int __USE_ATFILE = 1;

const int __USE_FORTIFY_LEVEL = 0;

const int __GLIBC_USE_DEPRECATED_GETS = 0;

const int __GLIBC_USE_DEPRECATED_SCANF = 0;

const int _STDC_PREDEF_H = 1;

const int __STDC_IEC_559__ = 1;

const int __STDC_IEC_60559_BFP__ = 201404;

const int __STDC_IEC_559_COMPLEX__ = 1;

const int __STDC_IEC_60559_COMPLEX__ = 201404;

const int __STDC_ISO_10646__ = 201706;

const int __GNU_LIBRARY__ = 6;

const int __GLIBC__ = 2;

const int __GLIBC_MINOR__ = 35;

const int _SYS_CDEFS_H = 1;

const int __THROW = 1;

const int __THROWNL = 1;

const int __glibc_c99_flexarr_available = 1;

const int __LDOUBLE_REDIRECTS_TO_FLOAT128_ABI = 0;

const int __HAVE_GENERIC_SELECTION = 0;

const int __GLIBC_USE_LIB_EXT2 = 1;

const int __GLIBC_USE_IEC_60559_BFP_EXT = 1;

const int __GLIBC_USE_IEC_60559_BFP_EXT_C2X = 1;

const int __GLIBC_USE_IEC_60559_EXT = 1;

const int __GLIBC_USE_IEC_60559_FUNCS_EXT = 1;

const int __GLIBC_USE_IEC_60559_FUNCS_EXT_C2X = 1;

const int __GLIBC_USE_IEC_60559_TYPES_EXT = 1;

const int _BITS_TYPES_H = 1;

const int _BITS_TYPESIZES_H = 1;

const int __OFF_T_MATCHES_OFF64_T = 1;

const int __INO_T_MATCHES_INO64_T = 1;

const int __RLIM_T_MATCHES_RLIM64_T = 1;

const int __STATFS_MATCHES_STATFS64 = 1;

const int __KERNEL_OLD_TIMEVAL_MATCHES_TIMEVAL64 = 1;

const int __FD_SETSIZE = 1024;

const int _BITS_TIME64_H = 1;

const int _BITS_WCHAR_H = 1;

const int __WCHAR_MAX = 2147483647;

const int __WCHAR_MIN = -2147483648;

const int _BITS_STDINT_INTN_H = 1;

const int _BITS_STDINT_UINTN_H = 1;

const int INT8_MIN = -128;

const int INT16_MIN = -32768;

const int INT32_MIN = -2147483648;

const int INT64_MIN = -9223372036854775808;

const int INT8_MAX = 127;

const int INT16_MAX = 32767;

const int INT32_MAX = 2147483647;

const int INT64_MAX = 9223372036854775807;

const int UINT8_MAX = 255;

const int UINT16_MAX = 65535;

const int UINT32_MAX = 4294967295;

const int UINT64_MAX = -1;

const int INT_LEAST8_MIN = -128;

const int INT_LEAST16_MIN = -32768;

const int INT_LEAST32_MIN = -2147483648;

const int INT_LEAST64_MIN = -9223372036854775808;

const int INT_LEAST8_MAX = 127;

const int INT_LEAST16_MAX = 32767;

const int INT_LEAST32_MAX = 2147483647;

const int INT_LEAST64_MAX = 9223372036854775807;

const int UINT_LEAST8_MAX = 255;

const int UINT_LEAST16_MAX = 65535;

const int UINT_LEAST32_MAX = 4294967295;

const int UINT_LEAST64_MAX = -1;

const int INT_FAST8_MIN = -128;

const int INT_FAST16_MIN = -9223372036854775808;

const int INT_FAST32_MIN = -9223372036854775808;

const int INT_FAST64_MIN = -9223372036854775808;

const int INT_FAST8_MAX = 127;

const int INT_FAST16_MAX = 9223372036854775807;

const int INT_FAST32_MAX = 9223372036854775807;

const int INT_FAST64_MAX = 9223372036854775807;

const int UINT_FAST8_MAX = 255;

const int UINT_FAST16_MAX = -1;

const int UINT_FAST32_MAX = -1;

const int UINT_FAST64_MAX = -1;

const int INTPTR_MIN = -9223372036854775808;

const int INTPTR_MAX = 9223372036854775807;

const int UINTPTR_MAX = -1;

const int INTMAX_MIN = -9223372036854775808;

const int INTMAX_MAX = 9223372036854775807;

const int UINTMAX_MAX = -1;

const int PTRDIFF_MIN = -9223372036854775808;

const int PTRDIFF_MAX = 9223372036854775807;

const int SIG_ATOMIC_MIN = -2147483648;

const int SIG_ATOMIC_MAX = 2147483647;

const int SIZE_MAX = -1;

const int WCHAR_MIN = -2147483648;

const int WCHAR_MAX = 2147483647;

const int WINT_MIN = 0;

const int WINT_MAX = 4294967295;

const int _STDLIB_H = 1;

const int WNOHANG = 1;

const int WUNTRACED = 2;

const int WSTOPPED = 2;

const int WEXITED = 4;

const int WCONTINUED = 8;

const int WNOWAIT = 16777216;

const int __WNOTHREAD = 536870912;

const int __WALL = 1073741824;

const int __WCLONE = 2147483648;

const int __W_CONTINUED = 65535;

const int __WCOREFLAG = 128;

const int __HAVE_FLOAT128 = 0;

const int __HAVE_DISTINCT_FLOAT128 = 0;

const int __HAVE_FLOAT64X = 1;

const int __HAVE_FLOAT64X_LONG_DOUBLE = 1;

const int __HAVE_FLOAT16 = 0;

const int __HAVE_FLOAT32 = 1;

const int __HAVE_FLOAT64 = 1;

const int __HAVE_FLOAT32X = 1;

const int __HAVE_FLOAT128X = 0;

const int __HAVE_DISTINCT_FLOAT16 = 0;

const int __HAVE_DISTINCT_FLOAT32 = 0;

const int __HAVE_DISTINCT_FLOAT64 = 0;

const int __HAVE_DISTINCT_FLOAT32X = 0;

const int __HAVE_DISTINCT_FLOAT64X = 0;

const int __HAVE_DISTINCT_FLOAT128X = 0;

const int __HAVE_FLOAT128_UNLIKE_LDBL = 0;

const int __HAVE_FLOATN_NOT_TYPEDEF = 0;

const int __ldiv_t_defined = 1;

const int __lldiv_t_defined = 1;

const int RAND_MAX = 2147483647;

const int EXIT_FAILURE = 1;

const int EXIT_SUCCESS = 0;

const int _SYS_TYPES_H = 1;

const int __clock_t_defined = 1;

const int __clockid_t_defined = 1;

const int __time_t_defined = 1;

const int __timer_t_defined = 1;

const int __BIT_TYPES_DEFINED__ = 1;

const int _ENDIAN_H = 1;

const int _BITS_ENDIAN_H = 1;

const int __LITTLE_ENDIAN = 1234;

const int __BIG_ENDIAN = 4321;

const int __PDP_ENDIAN = 3412;

const int _BITS_ENDIANNESS_H = 1;

const int __BYTE_ORDER = 1234;

const int __FLOAT_WORD_ORDER = 1234;

const int LITTLE_ENDIAN = 1234;

const int BIG_ENDIAN = 4321;

const int PDP_ENDIAN = 3412;

const int BYTE_ORDER = 1234;

const int _BITS_BYTESWAP_H = 1;

const int _BITS_UINTN_IDENTITY_H = 1;

const int _SYS_SELECT_H = 1;

const int __sigset_t_defined = 1;

const int _SIGSET_NWORDS = 16;

const int __timeval_defined = 1;

const int _STRUCT_TIMESPEC = 1;

const int __NFDBITS = 64;

const int FD_SETSIZE = 1024;

const int NFDBITS = 64;

const int _BITS_PTHREADTYPES_COMMON_H = 1;

const int _THREAD_SHARED_TYPES_H = 1;

const int _BITS_PTHREADTYPES_ARCH_H = 1;

const int __SIZEOF_PTHREAD_MUTEX_T = 40;

const int __SIZEOF_PTHREAD_ATTR_T = 56;

const int __SIZEOF_PTHREAD_RWLOCK_T = 56;

const int __SIZEOF_PTHREAD_BARRIER_T = 32;

const int __SIZEOF_PTHREAD_MUTEXATTR_T = 4;

const int __SIZEOF_PTHREAD_COND_T = 48;

const int __SIZEOF_PTHREAD_CONDATTR_T = 4;

const int __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;

const int __SIZEOF_PTHREAD_BARRIERATTR_T = 4;

const int _THREAD_MUTEX_INTERNAL_H = 1;

const int __PTHREAD_MUTEX_HAVE_PREV = 1;

const int __PTHREAD_RWLOCK_ELISION_EXTRA = 0;

const int __have_pthread_attr_t = 1;

const int _ALLOCA_H = 1;
