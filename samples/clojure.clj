(ns ergolight.sample
  (:require [clojure.string :as str]))

(def ^:private version "1.0.0")

(defprotocol Renderable
  (render [this]))

(defrecord Order [id status amount]
  Renderable
  (render [_]
    (str version ":" id ":" (name status) ":" amount)))

(defn summarize
  "Exercise keywords, symbols, metadata, strings, numbers and function calls."
  [orders]
  (->> orders
       (map render)
       (str/join "\n")))

(comment
  (summarize [(->Order 1 :paid 19.90M)]))

