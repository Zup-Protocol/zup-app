import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/concentrated_liquidity_utils/cl_sqrt_price_math_mixin.dart';

class _Sut with CLSqrtPriceMath {}

void main() {
  late _Sut sut;

  setUp(() {
    sut = _Sut();
  });

  test("When passing a sqrtPriceX96 to `sqrtPriceX96ToPrice` it should return the correct price", () {
    final prices = sut.sqrtPriceX96ToPrice(
      sqrtPriceX96: BigInt.parse("5240418162556390792557189"),
      poolToken0Decimals: 18,
      poolToken1Decimals: 6,
    );

    expect(prices.token0PerToken1, 4374.946221380494, reason: "`token0PerToken1` is not correct");
    expect(prices.token1PerToken0, 0.00022857423826445452, reason: "`token1PerToken0` is not correct");
  });

  test(
    """When calling 'getAmount0Delta' with sqrtRatioAX96 greater than sqrtRatioBX96 it should exchange them,
  and return the correct value""",
    () {
      final sqrtRatioAX96 = BigInt.parse("5240418162556390792557189");
      final sqrtRatioBX96 = BigInt.parse("5240418162556390792111188");
      final liquidity = BigInt.parse("100000000000000000000000000");

      final delta = sut.getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity, false);

      expect(delta, BigInt.parse("128671845471"));
    },
  );

  test(
    """When calling 'getAmount0Delta' with sqrtRatioAX96 less than sqrtRatioBX96 it should,
    return the correct value""",
    () {
      final sqrtRatioAX96 = BigInt.parse("19271902719072981");
      final sqrtRatioBX96 = BigInt.parse("8632786378263726372");
      final liquidity = BigInt.parse("88288282261567");

      final delta = sut.getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity, false);

      expect(delta, BigInt.parse("362149133068570772354378451"));
    },
  );

  test(
    """When calling 'getAmoun0Delta' with roundUp set to true it should not truncate the value
  but instead round it up""",
    () {
      final sqrtRatioAX96 = BigInt.parse("1111111111119091919191");
      final sqrtRatioBX96 = BigInt.parse("3312413425190");
      final liquidity = BigInt.parse("2781627156271");

      final delta = sut.getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity, true);

      expect(delta, BigInt.parse("66532518573368692340871338459"));
    },
  );

  test(
    """When calling 'getAmount1Delta' with sqrtRatioAX96 greater than sqrtRatioBX96 it should exchange them,
  and return the correct value""",
    () {
      final sqrtRatioAX96 = BigInt.parse("5240418162556390792557189");
      final sqrtRatioBX96 = BigInt.parse("5240418162556390792111188");
      final liquidity = BigInt.parse("100000000000000000000000000");

      final delta = sut.getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity, false);

      expect(delta, BigInt.parse("562"));
    },
  );

  test(
    """When calling 'getAmount1Delta' with sqrtRatioAX96 less than sqrtRatioBX96 it should,
    return the correct value""",
    () {
      final sqrtRatioAX96 = BigInt.parse("19271902719072981");
      final sqrtRatioBX96 = BigInt.parse("8632786378263726372");
      final liquidity = BigInt.parse("88288282261567");

      final delta = sut.getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity, false);

      expect(delta, BigInt.parse("9598"));
    },
  );

  test(
    """When calling 'getAmount1Delta' with roundUp set to true it should not truncate the value
  but instead round it up""",
    () {
      final sqrtRatioAX96 = BigInt.parse("1111111111119091919191");
      final sqrtRatioBX96 = BigInt.parse("3312413425190");
      final liquidity = BigInt.parse("2781627156271");

      final delta = sut.getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, liquidity, true);

      expect(delta, BigInt.parse("39011"));
    },
  );

  test(
    """When calling 'getAmountsDeltas' with the sqrtPriceX96
    lower than the sqrtPriceAX96 it should calculate only the
    amount0 delta, and the amount1 should be zero""",
    () {
      final sqrtPriceX96 = BigInt.parse("19271902719");
      final sqrtPriceAX96 = BigInt.parse("5240418162556");
      final sqrtPriceBX96 = BigInt.parse("8632786378263726372");

      final liquidity = BigInt.parse("88288282261567");

      final amountsDeltas = sut.getAmountsDeltas(sqrtPriceX96, sqrtPriceAX96, sqrtPriceBX96, liquidity);

      expect(amountsDeltas.amount0Delta, BigInt.parse("1334800756728304192095196701447"));
      expect(amountsDeltas.amount1Delta, BigInt.zero);
    },
  );

  test(
    """When calling 'getAmountsDeltas' with the sqrtPriceX96
    greater than the sqrtPriceAX96, but lower than B, this mean
    the prices are in range, so both amounts should be calculed""",
    () {
      final sqrtPriceX96 = BigInt.parse("52404181625563907925571");
      final sqrtPriceAX96 = BigInt.parse("524041816255639079");
      final sqrtPriceBX96 = BigInt.parse("5240418162556390792557189");

      final liquidity = BigInt.parse("1903728937892");

      final amountsDeltas = sut.getAmountsDeltas(sqrtPriceX96, sqrtPriceAX96, sqrtPriceBX96, liquidity);

      expect(amountsDeltas.amount0Delta, BigInt.parse("2849403455712571914"));
      expect(amountsDeltas.amount1Delta, BigInt.parse("1259179"));
    },
  );

  test(
    """When calling 'getAmountsDeltas' with the sqrtPriceX96
    lower than the sqrtPriceAX96, but sqrtPriceA is greater
    than B, this mean the prices are reversed, so the 
    B should be reversed to A and A to B, and then
    calculate the amounts, as they are in range""",
    () {
      final sqrtPriceX96 = BigInt.parse("52404181625563907925571");
      final sqrtPriceAX96 = BigInt.parse("5240418162556390792557189");
      final sqrtPriceBX96 = BigInt.parse("524041816255639079");

      final liquidity = BigInt.parse("1903728937892");

      final amountsDeltas = sut.getAmountsDeltas(sqrtPriceX96, sqrtPriceAX96, sqrtPriceBX96, liquidity);

      expect(amountsDeltas.amount0Delta, BigInt.parse("2849403455712571914"));
      expect(amountsDeltas.amount1Delta, BigInt.parse("1259179"));
    },
  );

  test(
    """When calling 'getAmountsDeltas' with the sqrtPriceX96
    greater than A, and B, this mean it's out of range (upper side)
    it should calculate only the delta for the amount 1""",
    () {
      final sqrtPriceX96 = BigInt.parse("52404181625563907925571");
      final sqrtPriceAX96 = BigInt.parse("524041816255907");
      final sqrtPriceBX96 = BigInt.parse("524041816255");

      final liquidity = BigInt.parse("897987283288888029739287");

      final amountsDeltas = sut.getAmountsDeltas(sqrtPriceX96, sqrtPriceAX96, sqrtPriceBX96, liquidity);

      expect(amountsDeltas.amount0Delta, BigInt.zero);
      expect(amountsDeltas.amount1Delta, BigInt.parse("5933651484"));
    },
  );
}
