#define BOOST_TEST_DYN_LINK
#include <boost/test/unit_test.hpp>

#include "metric/ir/tndcg.h"
#include "data/dataset.h"
#include <cmath>

BOOST_AUTO_TEST_CASE( tndcg_test ) {
  quickrank::Label labels[] = { 3, 2, 1, 0, 0 };
  quickrank::Score scores[] = { 5, 4, 3, 2, 1 };
  quickrank::data::QueryResults results(5, &labels[0], NULL);

  quickrank::metric::ir::Tndcg tndcg_metric(5);
  quickrank::MetricScore idcg;

  // NDCG@k computation with K > num results
  idcg = (pow(2, labels[0]) - 1) + (pow(2, labels[1]) - 1) / log2(3)
          + (pow(2, labels[2]) - 1) / 2;

  BOOST_CHECK_EQUAL(
      tndcg_metric.evaluate_result_list(&results, scores),
      1.0);

  scores[0] = 4;
  BOOST_CHECK_EQUAL(
      tndcg_metric.evaluate_result_list(&results, scores),
      (
          (  (pow(2, labels[0]) - 1) + (pow(2, labels[1]) - 1)  ) / 2 +
          (  (pow(2, labels[0]) - 1) + (pow(2, labels[1]) - 1)  ) / 2 / log2(3) +
          (pow(2, labels[2]) - 1) / 2
      ) / idcg );

  scores[1] = 3;
  BOOST_CHECK_EQUAL(
      tndcg_metric.evaluate_result_list(&results, scores),
      (
          (pow(2, labels[0]) - 1) +
          (  (pow(2, labels[1]) - 1) + (pow(2, labels[2]) - 1)  ) / 2 / log2(3) +
          (  (pow(2, labels[1]) - 1) + (pow(2, labels[2]) - 1)  ) / 2 / 2
      ) / idcg );


  /*
  // NDCG@k computation with K = 0
  ndcg_metric.set_cutoff(0);
  BOOST_CHECK_EQUAL(
      tndcg_metric.evaluate_result_list(&results, scores),
      ((pow(2, labels[0]) - 1) + (pow(2, labels[1]) - 1) / log2(3)
          + (pow(2, labels[2]) - 1) / 2) / idcg);

  // NDCG@k computation with K = No cutoff
  ndcg_metric.set_cutoff(ndcg_metric.NO_CUTOFF);
  BOOST_CHECK_EQUAL(
      tndcg_metric.evaluate_result_list(&results, scores),
      ((pow(2, labels[0]) - 1) + (pow(2, labels[1]) - 1) / log2(3)
          + (pow(2, labels[2]) - 1) / 2) / idcg);

  // NDCG@k computation with K < num results
  ndcg_metric.set_cutoff(2);
  idcg = (pow(2, labels[0]) - 1) + (pow(2, labels[1]) - 1) / log2(3);
  BOOST_CHECK_EQUAL(
      tndcg_metric.evaluate_result_list(&results, scores),
      ((pow(2, labels[0]) - 1) + (pow(2, labels[1]) - 1) / log2(3)) / idcg);
   */
}